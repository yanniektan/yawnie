import Foundation

/// Everything the user sets once: city, budget, checklists, printer and a few skill knobs.
/// Missing keys decode to their defaults, so adding a field never wipes saved settings.
struct AppSettings: Codable, Equatable {
    var city = "New York, NY"
    /// The stock-budget bar compares yesterday's spend with this divided by the days in the month.
    var monthlyBudget: Decimal = 0
    var staples: [ChecklistItem] = ChecklistItem.defaultStaples
    var amenities: [ChecklistItem] = []
    /// The stock-yoga bar looks for the next class after this time.
    var workFinish = TimeOfDay(hour: 18, minute: 0)
    /// The sad-songs skill counts a track as on repeat at this many plays.
    var repeatThreshold = 3
    /// Senders the inbox clean-up always skips (an address or a domain).
    var protectedSenders: [String] = []
    var printer: SavedPrinter?

    static let repeatRange = 2...10

    init() {}

    func dailyBudgetCap(on date: Date, calendar: Calendar = .current) -> Decimal {
        let days = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
        return monthlyBudget / Decimal(days)
    }

    /// What the edition builder needs from Settings. The printer stays on the phone.
    func editionPreferences(on date: Date, calendar: Calendar = .current) -> EditionPreferences {
        EditionPreferences(
            city: city,
            dailyBudgetCap: dailyBudgetCap(on: date, calendar: calendar),
            staples: staples.map(EditionPreferences.Item.init),
            amenities: amenities.map(EditionPreferences.Item.init),
            workFinish: workFinish.description,
            repeatThreshold: repeatThreshold,
            protectedSenders: protectedSenders
        )
    }

    private enum CodingKeys: String, CodingKey {
        case city, monthlyBudget, staples, amenities, workFinish, repeatThreshold, protectedSenders, printer
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = AppSettings()
        city = try c.decodeIfPresent(String.self, forKey: .city) ?? defaults.city
        monthlyBudget = try c.decodeIfPresent(Decimal.self, forKey: .monthlyBudget) ?? defaults.monthlyBudget
        staples = try c.decodeIfPresent([ChecklistItem].self, forKey: .staples) ?? defaults.staples
        amenities = try c.decodeIfPresent([ChecklistItem].self, forKey: .amenities) ?? defaults.amenities
        workFinish = try c.decodeIfPresent(TimeOfDay.self, forKey: .workFinish) ?? defaults.workFinish
        repeatThreshold = try c.decodeIfPresent(Int.self, forKey: .repeatThreshold) ?? defaults.repeatThreshold
        protectedSenders = try c.decodeIfPresent([String].self, forKey: .protectedSenders) ?? defaults.protectedSenders
        printer = try c.decodeIfPresent(SavedPrinter.self, forKey: .printer)
    }
}

struct ChecklistItem: Codable, Equatable, Identifiable {
    var id = UUID()
    var name: String
    /// The item's Amazon product page. The Buy button builds one add-to-cart link from these.
    var productURL: URL?

    static let defaultStaples = ["Grapes", "Strawberries", "Yogurt", "Granola", "Salad"]
        .map { ChecklistItem(name: $0) }

    enum Problem: Error, Equatable {
        case emptyName
        case notALink
        case notAmazon

        var message: String {
            switch self {
            case .emptyName: return "Give the item a name."
            case .notALink: return "That doesn't look like a web link."
            case .notAmazon: return "Paste the item's Amazon product link."
            }
        }
    }

    /// Checks what the user typed. An empty link is fine; a non-empty one must be an https Amazon link.
    static func validated(name: String, link: String) -> Result<ChecklistItem, Problem> {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let link = link.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return .failure(.emptyName) }
        guard !link.isEmpty else { return .success(ChecklistItem(name: name)) }
        guard let url = URL(string: link), url.scheme?.lowercased() == "https", let host = url.host?.lowercased() else {
            return .failure(.notALink)
        }
        let amazonHosts = ["amazon.com", "amzn.to", "a.co"]
        guard amazonHosts.contains(where: { host == $0 || host.hasSuffix("." + $0) }) else {
            return .failure(.notAmazon)
        }
        return .success(ChecklistItem(name: name, productURL: url))
    }
}

struct TimeOfDay: Codable, Equatable, CustomStringConvertible {
    var hour: Int
    var minute: Int

    /// `HH:mm`, 24-hour.
    var description: String { String(format: "%02d:%02d", hour, minute) }

    func date(on day: Date, calendar: Calendar = .current) -> Date {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }

    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }

    init(_ date: Date, calendar: Calendar = .current) {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        self.init(hour: parts.hour ?? 0, minute: parts.minute ?? 0)
    }
}

struct SavedPrinter: Codable, Equatable {
    var url: URL
    var name: String
}

/// The part of Settings sent to the backend as device context.
struct EditionPreferences: Encodable, Equatable {
    struct Item: Encodable, Equatable {
        var name: String
        var productURL: URL?

        init(_ item: ChecklistItem) {
            name = item.name
            productURL = item.productURL
        }
    }

    var city: String
    var dailyBudgetCap: Decimal
    var staples: [Item]
    var amenities: [Item]
    var workFinish: String
    var repeatThreshold: Int
    var protectedSenders: [String]
}
