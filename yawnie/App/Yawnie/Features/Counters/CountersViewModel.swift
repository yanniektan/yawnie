import Foundation
import Observation

@MainActor
@Observable
final class CountersViewModel {
    /// Nil until the first read succeeds.
    private(set) var tally: CountersTally?
    /// Set when a tap was not saved or the counters could not be read.
    private(set) var problem: String?

    private let service: CountersService
    private let timeZone: TimeZone
    private let now: () -> Date
    /// Rows the backend has confirmed.
    private var saved: [CounterRow] = []
    /// Taps shown at once while they save.
    private var pending: [UUID: CounterRow] = [:]
    private var writes = 0

    init(service: CountersService, timeZone: TimeZone = .current, now: @escaping () -> Date = Date.init) {
        self.service = service
        self.timeZone = timeZone
        self.now = now
    }

    var today: String { CounterDay.day(for: now(), in: timeZone) }

    func load() async {
        let today = today
        let writesBefore = writes
        guard let first = CountersTally.days(endingOn: today)?.first else { return }
        do {
            let rows = try await service.rows(from: first, through: today)
            // A tap saved during the read may be missing from it, so read again.
            guard writes == writesBefore else { return await load() }
            saved = rows
            problem = nil
            recount(today)
        } catch {
            problem = "Counters not available."
        }
    }

    /// Ate out and buckled add one. Piano and stretched switch between yes and no.
    func tap(_ kind: CounterKind) async {
        let today = today
        let sum = rawSum(kind, on: today)
        let value = kind.isYesNo && sum > 0 ? -sum : 1
        await record(CounterRow(day: today, kind: kind.rawValue, value: value))
    }

    /// Takes back one tap from today's ate out or buckled.
    func removeOne(_ kind: CounterKind) async {
        let today = today
        guard !kind.isYesNo, rawSum(kind, on: today) > 0 else { return }
        await record(CounterRow(day: today, kind: kind.rawValue, value: -1))
    }

    private func record(_ row: CounterRow) async {
        let id = UUID()
        pending[id] = row
        recount(row.day)
        do {
            try await service.add(row)
            saved.append(row)
            writes += 1
            problem = nil
        } catch {
            problem = "Not saved. Tap again."
        }
        pending[id] = nil
        recount(row.day)
    }

    private var rows: [CounterRow] { saved + pending.values }

    private func rawSum(_ kind: CounterKind, on day: String) -> Int {
        rows.filter { $0.kind == kind.rawValue && $0.day == day }.reduce(0) { $0 + $1.value }
    }

    private func recount(_ today: String) {
        tally = CountersTally(rows: rows, today: today)
    }
}
