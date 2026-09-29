import Foundation
import Observation

@MainActor
@Observable
final class DailyViewModel {
    private(set) var edition: Edition?
    private(set) var isBuilding = false
    /// A one-line note under the masthead, such as "Couldn't update. Showing the saved copy."
    private(set) var notice: String?

    let settings: SettingsStore

    @ObservationIgnored private let provider: EditionProvider
    @ObservationIgnored private let cache: EditionCache?
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let calendar: Calendar

    init(
        provider: EditionProvider,
        settings: SettingsStore,
        cache: EditionCache? = .standard,
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init
    ) {
        self.provider = provider
        self.settings = settings
        self.cache = cache
        self.calendar = calendar
        self.now = now
    }

    var isSample: Bool { provider.isSample }

    /// Shows the saved copy at once, then builds today's.
    func load() async {
        if edition == nil { edition = cache?.load() }
        await refresh()
    }

    func refresh() async {
        guard !isBuilding else { return }
        isBuilding = true
        defer { isBuilding = false }
        do {
            let fresh = try await provider.buildEdition(for: deviceContext())
            edition = fresh
            notice = nil
            if !provider.isSample { try? cache?.save(fresh) }
        } catch {
            notice = edition == nil
                ? "The paper couldn't be built. Pull down to try again."
                : "Couldn't update. Showing the saved copy."
        }
    }

    /// Builds again when the app comes back on a new day.
    func refreshIfStale() async {
        guard edition?.day != Self.dayString(now(), calendar: calendar) else { return }
        await refresh()
    }

    func deviceContext() -> DeviceContext {
        let date = now()
        return DeviceContext(
            day: Self.dayString(date, calendar: calendar),
            timeZone: calendar.timeZone.identifier,
            preferences: settings.settings.editionPreferences(on: date, calendar: calendar)
        )
    }

    // MARK: Page

    /// The printed sections in page order. Action blocks (cta-*) feed the buttons, not the page.
    var sections: [SkillResult] {
        PageLayout.arrange(edition?.results ?? [])
    }

    func result(for action: DailyAction) -> SkillResult? {
        action.skill.flatMap { edition?.result(for: $0) }
    }

    /// "WEDNESDAY, SEPTEMBER 30, 2026 · NEW YORK, NY"
    var dateline: String {
        let day = edition.flatMap { Self.date(from: $0.day, calendar: calendar) } ?? now()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        let city = settings.settings.city.trimmingCharacters(in: .whitespaces)
        let parts = [formatter.string(from: day), city].filter { !$0.isEmpty }
        return parts.joined(separator: " · ").uppercased()
    }

    static func dayString(_ date: Date, calendar: Calendar) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    static func date(from day: String, calendar: Calendar) -> Date? {
        let parts = day.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }
}

/// Section order on the page. Mirrors `Paper/template.html`: counters first, the comic last.
enum PageLayout {
    static let order = [
        "counters", "weather-outfit", "profg-insights",
        "stock-groceries", "stock-yoga", "stock-budget",
        "social-hours", "sad-songs", "deep-dive", "chem-fact", "comic",
    ]

    static func arrange(_ results: [SkillResult]) -> [SkillResult] {
        let printed = results.filter { !$0.skill.hasPrefix("cta-") }
        // Skills the template doesn't know yet go just above the comic.
        let comicRank = Double(order.firstIndex(of: "comic") ?? order.count)
        func rank(_ skill: String) -> Double { order.firstIndex(of: skill).map(Double.init) ?? comicRank - 0.5 }
        return printed.enumerated()
            .sorted { a, b in
                let (ra, rb) = (rank(a.element.skill), rank(b.element.skill))
                return ra != rb ? ra < rb : a.offset < b.offset
            }
            .map(\.element)
    }

    static func title(for skill: String) -> String {
        switch skill {
        case "counters": return "Counters"
        case "weather-outfit": return "Weather"
        case "profg-insights": return "Markets"
        case "stock-groceries": return "Groceries"
        case "stock-yoga": return "Yoga"
        case "stock-budget": return "Budget"
        case "social-hours": return "Social media"
        case "sad-songs": return "On repeat"
        case "deep-dive": return "Deep dive"
        case "chem-fact": return "Chemistry"
        case "comic": return "Comic"
        default: return skill.replacingOccurrences(of: "-", with: " ").capitalized
        }
    }
}
