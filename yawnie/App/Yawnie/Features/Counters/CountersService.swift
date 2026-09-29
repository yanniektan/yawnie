import Foundation

/// Reads and appends counters rows. Rows are never edited: an undo is a row with value -1.
protocol CountersService: Sendable {
    /// Rows whose day falls between `first` and `last`, both included.
    func rows(from first: String, through last: String) async throws -> [CounterRow]
    func add(_ row: CounterRow) async throws
}

enum CountersServiceError: Error, Equatable {
    case http(status: Int)
}

/// The counters table through Supabase's REST API. Row-level security limits every
/// request to the signed-in user, and `user_id` defaults to `auth.uid()`.
struct SupabaseCountersService: CountersService {
    var projectURL: URL
    var anonKey: String
    var accessToken: @Sendable () async throws -> String
    var session: URLSession = .shared

    private var tableURL: URL { projectURL.appendingPathComponent("rest/v1/counters") }

    func rows(from first: String, through last: String) async throws -> [CounterRow] {
        var components = URLComponents(url: tableURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "select", value: "day,kind,value"),
            URLQueryItem(name: "day", value: "gte.\(first)"),
            URLQueryItem(name: "day", value: "lte.\(last)"),
        ]
        let data = try await send(URLRequest(url: components.url!))
        return try JSONDecoder().decode([CounterRow].self, from: data)
    }

    func add(_ row: CounterRow) async throws {
        var request = URLRequest(url: tableURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        request.httpBody = try JSONEncoder().encode(row)
        _ = try await send(request)
    }

    private func send(_ request: URLRequest) async throws -> Data {
        var request = request
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(try await accessToken())", forHTTPHeaderField: "Authorization")
        let (data, response) = try await session.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else { throw CountersServiceError.http(status: status) }
        return data
    }
}

/// Keeps rows in memory, for previews and tests.
actor InMemoryCountersService: CountersService {
    private(set) var rows: [CounterRow]

    init(rows: [CounterRow] = []) {
        self.rows = rows
    }

    func rows(from first: String, through last: String) async throws -> [CounterRow] {
        rows.filter { $0.day >= first && $0.day <= last }
    }

    func add(_ row: CounterRow) async throws {
        rows.append(row)
    }
}

extension InMemoryCountersService {
    /// Rows rebuilt from the counters block in Paper/sample/edition.sample.json, ending on `today`.
    static func sample(today: String, bundle: Bundle = .main) -> InMemoryCountersService {
        guard let url = bundle.url(forResource: "edition.sample", withExtension: "json", subdirectory: "Paper/sample"),
              let data = try? Data(contentsOf: url),
              let edition = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = edition["results"] as? [[String: Any]],
              let block = results.first(where: { $0["skill"] as? String == "counters" })?["block"] as? [String: Any],
              let days = CountersTally.days(endingOn: today)
        else { return InMemoryCountersService() }

        let week = block["week"] as? [String: [Int]] ?? [:]
        let todayValues = block["today"] as? [String: Any] ?? [:]
        var rows: [CounterRow] = []
        for kind in CounterKind.allCases {
            var series = week[kind.rawValue] ?? [Int](repeating: 0, count: 7)
            if let value = todayValues[kind.rawValue] as? Bool {
                series[6] = value ? 1 : 0
            } else if let value = todayValues[kind.rawValue] as? Int {
                series[6] = value
            }
            for (day, value) in zip(days, series) where value != 0 {
                rows.append(CounterRow(day: day, kind: kind.rawValue, value: value))
            }
        }
        return InMemoryCountersService(rows: rows)
    }
}
