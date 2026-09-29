import Foundation

enum CounterKind: String, CaseIterable, Codable, Identifiable, Sendable {
    case ateOut = "ate_out"
    case buckled
    case piano
    case stretched

    var id: String { rawValue }

    /// Ate out and buckled count taps. Piano and stretched are yes or no for the day.
    var isYesNo: Bool { self == .piano || self == .stretched }

    var title: String {
        switch self {
        case .ateOut: return "ATE OUT"
        case .buckled: return "BUCKLED"
        case .piano: return "PIANO"
        case .stretched: return "STRETCHED"
        }
    }
}

/// One row of the counters table. `kind` stays a string so an unknown kind is skipped, not fatal.
struct CounterRow: Codable, Equatable, Sendable {
    var day: String
    var kind: String
    var value: Int
}

/// Counter days are YYYY-MM-DD strings, the same as the `day` column.
enum CounterDay {
    /// A tap before this local hour counts for the previous day.
    static let cutoffHour = 12

    private static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    /// The counter day `date` belongs to in `timeZone`.
    static func day(for date: Date, in timeZone: TimeZone) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let parts = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        let local = String(format: "%04d-%02d-%02d", parts.year!, parts.month!, parts.day!)
        return parts.hour! < cutoffHour ? adding(-1, to: local)! : local
    }

    /// Nil when `day` is not a real YYYY-MM-DD date.
    static func adding(_ days: Int, to day: String) -> String? {
        let parts = day.split(separator: "-")
        guard day.count == 10, parts.count == 3,
              let year = Int(parts[0]), let month = Int(parts[1]), let date = Int(parts[2]),
              let start = utc.date(from: DateComponents(year: year, month: month, day: date)),
              string(from: start) == day,
              let result = utc.date(byAdding: .day, value: days, to: start)
        else { return nil }
        return string(from: result)
    }

    private static func string(from date: Date) -> String {
        let parts = utc.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year!, parts.month!, parts.day!)
    }
}

/// Today's value and the last seven days for each counter. Mirrors skills/counters/tally.ts.
struct CountersTally: Equatable, Sendable {
    /// The counter day the series ends on.
    var today: String
    /// Seven values per kind, oldest first, ending with today. Yes-or-no kinds use 1 and 0.
    var week: [CounterKind: [Int]]

    /// Nil when `today` is not a valid day.
    init?(rows: [CounterRow], today: String) {
        guard let days = Self.days(endingOn: today) else { return nil }
        var sums = Dictionary(uniqueKeysWithValues: CounterKind.allCases.map { ($0, [Int](repeating: 0, count: 7)) })
        for row in rows {
            guard let kind = CounterKind(rawValue: row.kind), let i = days.firstIndex(of: row.day) else { continue }
            sums[kind]![i] += row.value
        }
        self.today = today
        self.week = [:]
        for (kind, series) in sums {
            week[kind] = series.map { kind.isYesNo ? ($0 > 0 ? 1 : 0) : max(0, $0) }
        }
    }

    /// The seven counter days ending on `today`, oldest first.
    static func days(endingOn today: String) -> [String]? {
        let days = (-6...0).compactMap { CounterDay.adding($0, to: today) }
        return days.count == 7 ? days : nil
    }

    func value(_ kind: CounterKind) -> Int { week[kind]?.last ?? 0 }

    func isYes(_ kind: CounterKind) -> Bool { value(kind) > 0 }

    func total(_ kind: CounterKind) -> Int { week[kind]?.reduce(0, +) ?? 0 }
}
