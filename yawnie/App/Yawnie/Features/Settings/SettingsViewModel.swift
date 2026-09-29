import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    enum ListKind: String, Identifiable, CaseIterable {
        case staples, amenities

        var id: String { rawValue }
        var title: String { self == .staples ? "Grocery staples" : "Amenities" }
    }

    let store: SettingsStore
    private(set) var isPickingPrinter = false
    @ObservationIgnored private let printerPicker: PrinterPicking

    init(store: SettingsStore, printerPicker: PrinterPicking = SystemPrinterPicker()) {
        self.store = store
        self.printerPicker = printerPicker
    }

    // MARK: Budget

    func dailyCapText(on date: Date = .now, calendar: Calendar = .current) -> String {
        let days = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
        let cap = store.settings.dailyBudgetCap(on: date, calendar: calendar)
        return "Daily cap \(cap.formatted(.currency(code: "USD"))) (monthly ÷ \(days) days)"
    }

    // MARK: Checklists

    func items(_ kind: ListKind) -> [ChecklistItem] {
        kind == .staples ? store.settings.staples : store.settings.amenities
    }

    func add(_ item: ChecklistItem, to kind: ListKind) {
        update(kind) { $0.append(item) }
    }

    func remove(at offsets: IndexSet, from kind: ListKind) {
        update(kind) { $0.remove(atOffsets: offsets) }
    }

    func move(from source: IndexSet, to destination: Int, in kind: ListKind) {
        update(kind) { $0.move(fromOffsets: source, toOffset: destination) }
    }

    private func update(_ kind: ListKind, _ change: (inout [ChecklistItem]) -> Void) {
        switch kind {
        case .staples: change(&store.settings.staples)
        case .amenities: change(&store.settings.amenities)
        }
    }

    // MARK: Protected senders

    /// Adds an address or domain. Returns a message to show if it was not added.
    @discardableResult
    func addProtectedSender(_ text: String) -> String? {
        let sender = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard Self.isSender(sender) else { return "Type an email address or a domain, like example.com." }
        guard !store.settings.protectedSenders.contains(sender) else { return "Already protected." }
        store.settings.protectedSenders.append(sender)
        return nil
    }

    func removeProtectedSenders(at offsets: IndexSet) {
        store.settings.protectedSenders.remove(atOffsets: offsets)
    }

    static func isSender(_ text: String) -> Bool {
        guard !text.isEmpty, !text.contains(where: \.isWhitespace) else { return false }
        let parts = text.split(separator: "@", omittingEmptySubsequences: false)
        switch parts.count {
        case 1: return isDomain(parts[0])
        case 2: return !parts[0].isEmpty && isDomain(parts[1])
        default: return false
        }
    }

    private static func isDomain(_ text: Substring) -> Bool {
        let labels = text.split(separator: ".", omittingEmptySubsequences: false)
        return labels.count >= 2 && labels.allSatisfy { !$0.isEmpty }
    }

    // MARK: Printer

    func choosePrinter() async {
        guard !isPickingPrinter else { return }
        isPickingPrinter = true
        defer { isPickingPrinter = false }
        if let printer = await printerPicker.pickPrinter(current: store.settings.printer) {
            store.settings.printer = printer
        }
    }

    func forgetPrinter() {
        store.settings.printer = nil
    }
}
