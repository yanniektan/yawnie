import SwiftUI

/// The five buttons under the page. They are on screen only and never print.
enum DailyAction: String, CaseIterable, Identifiable, Hashable {
    case groceries, amenities, inbox, parents, print

    var id: String { rawValue }

    var title: String {
        switch self {
        case .groceries: return "Groceries"
        case .amenities: return "Amenities"
        case .inbox: return "Inbox"
        case .parents: return "Parents"
        case .print: return "Print"
        }
    }

    var systemImage: String {
        switch self {
        case .groceries: return "cart"
        case .amenities: return "shippingbox"
        case .inbox: return "tray"
        case .parents: return "envelope"
        case .print: return "printer"
        }
    }

    /// The skill whose block feeds the action screen.
    var skill: String? {
        switch self {
        case .groceries: return "cta-groceries"
        case .amenities: return "cta-amenities"
        case .inbox: return "cta-inbox"
        case .parents: return "cta-parents"
        case .print: return nil
        }
    }
}

/// Where other features plug into the Daily without editing it.
/// The Actions/* screens and the Print service replace these defaults from `YawnieApp`.
struct DailyHooks {
    /// The screen behind each action button. Receives that action's block, if today's edition has one.
    var actionScreen: @MainActor (DailyAction, SkillResult?) -> AnyView = { action, result in
        AnyView(ActionPlaceholder(action: action, result: result))
    }
    /// Prints the edition. Nil until the Print service is wired in; the Print button is disabled meanwhile.
    var print: (@MainActor (Edition) -> Void)?
}

struct ActionStrip: View {
    let printEnabled: Bool
    let onTap: (DailyAction) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(DailyAction.allCases) { action in
                Button { onTap(action) } label: {
                    VStack(spacing: 4) {
                        Image(systemName: action.systemImage)
                            .font(.title3)
                        Text(action.title)
                            .font(.system(.caption2, design: .monospaced))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .contentShape(Rectangle())
                }
                .disabled(action == .print && !printEnabled)
                .accessibilityIdentifier("daily.action.\(action.rawValue)")
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 8)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
    }
}

/// Stands in for an action screen until its owner plugs in the real one.
struct ActionPlaceholder: View {
    let action: DailyAction
    let result: SkillResult?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let result {
                    BlockBody(block: result.block)
                } else {
                    Text("Nothing for \(action.title.lowercased()) in today's paper.")
                }
                Text("The full \(action.title.lowercased()) screen is on its way.")
                    .foregroundStyle(.secondary)
            }
            .font(.system(.body, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle(action.title)
    }
}
