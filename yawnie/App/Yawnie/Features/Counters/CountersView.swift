import SwiftUI

/// The four counters at the top of the Daily, each with its last seven days underneath.
struct CountersView: View {
    let model: CountersViewModel

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .top, spacing: 0) {
                ForEach(CounterKind.allCases) { kind in
                    if kind != CounterKind.allCases.first {
                        Divider()
                    }
                    CounterCell(
                        kind: kind,
                        tally: model.tally,
                        tap: { Task { await model.tap(kind) } },
                        removeOne: { Task { await model.removeOne(kind) } }
                    )
                }
            }
            .fixedSize(horizontal: false, vertical: true)

            if let problem = model.problem {
                HStack {
                    Text(problem)
                    if model.tally == nil {
                        Button("Try again") { Task { await model.load() } }
                    }
                }
                .font(.system(.caption, design: .monospaced))
            }
        }
        .task { await model.load() }
    }
}

private struct CounterCell: View {
    let kind: CounterKind
    let tally: CountersTally?
    let tap: () -> Void
    let removeOne: () -> Void

    var body: some View {
        Button(action: tap) {
            VStack(spacing: 4) {
                Text(kind.title)
                    .font(.system(.caption2, design: .monospaced))
                Text(todayText)
                    .font(.system(.title2, design: .monospaced).weight(.bold))
                Text(weekText)
                    .font(.system(.caption2, design: .monospaced))
            }
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(tally == nil)
        .contextMenu {
            if !kind.isYesNo, let tally, tally.value(kind) > 0 {
                Button("Remove one", action: removeOne)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(kind.title.capitalized)
        .accessibilityValue(accessibilityValue)
        .accessibilityHint(kind.isYesNo ? "Switches today between yes and no" : "Adds one for today")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: "Remove one") {
            if !kind.isYesNo { removeOne() }
        }
    }

    private var todayText: String {
        guard let tally else { return "-" }
        return kind.isYesNo ? (tally.isYes(kind) ? "YES" : "NO") : String(tally.value(kind))
    }

    /// Oldest first, today last. Yes is x and no is a dot.
    private var weekText: String {
        guard let series = tally?.week[kind] else { return " " }
        return series.map { kind.isYesNo ? ($0 > 0 ? "x" : ".") : String($0) }.joined(separator: " ")
    }

    private var accessibilityValue: String {
        guard let tally else { return "Not available" }
        if kind.isYesNo {
            return "\(tally.isYes(kind) ? "Yes" : "No") today, \(tally.total(kind)) of the last 7 days"
        }
        return "\(tally.value(kind)) today, \(tally.total(kind)) in the last 7 days"
    }
}

#if DEBUG
extension CountersViewModel {
    /// The sample edition's morning: 6:00 a.m. on 2026-09-30 in New York, counting for the 29th.
    static func sample() -> CountersViewModel {
        let timeZone = TimeZone(identifier: "America/New_York")!
        let now = ISO8601DateFormatter().date(from: "2026-09-30T10:00:00Z")!
        let service = InMemoryCountersService.sample(today: CounterDay.day(for: now, in: timeZone))
        return CountersViewModel(service: service, timeZone: timeZone, now: { now })
    }
}

#Preview {
    CountersView(model: .sample())
        .font(.system(.body, design: .monospaced))
        .padding()
}
#endif
