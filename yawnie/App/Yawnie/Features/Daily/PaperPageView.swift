import SwiftUI
import WebKit

/// The paper on screen. Uses the backend's HTML when the edition has it, so screen and print match;
/// otherwise draws the blocks natively in the same typewriter style.
struct PaperPageView: View {
    let edition: Edition
    let sections: [SkillResult]
    let dateline: String

    var body: some View {
        if let html = edition.html {
            PaperWebView(html: html)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Masthead(dateline: dateline)
                    ForEach(sections) { result in
                        SectionBox(result: result)
                        DoubleRule()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .background(Color.white)
            .foregroundStyle(Color.black)
            .environment(\.colorScheme, .light)
        }
    }
}

struct Masthead: View {
    let dateline: String

    var body: some View {
        VStack(spacing: 6) {
            Text("THE YAWNIE DAILY")
                .font(.system(.largeTitle, design: .monospaced).weight(.bold))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .accessibilityAddTraits(.isHeader)
            Text(dateline)
                .font(.system(.caption, design: .monospaced))
                .accessibilityIdentifier("daily.dateline")
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .overlay(alignment: .bottom) { DoubleRule(weight: 1.5) }
    }
}

/// Thin double rule between sections, as on the printed page.
struct DoubleRule: View {
    var weight: CGFloat = 1

    var body: some View {
        VStack(spacing: 2) {
            Rectangle().frame(height: weight)
            Rectangle().frame(height: weight)
        }
        .accessibilityHidden(true)
    }
}

struct SectionBox: View {
    let result: SkillResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(heading.uppercased())
                .font(.system(.headline, design: .monospaced))
                .accessibilityAddTraits(.isHeader)
            BlockBody(block: result.block)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("daily.section.\(result.skill)")
    }

    private var heading: String {
        switch result.block {
        case .text(let title, _, _), .number(let title, _, _), .bar(let title, _),
             .checklist(let title, _), .list(let title, _):
            return title
        default:
            return PageLayout.title(for: result.skill)
        }
    }
}

/// Draws one block's contents. Shared with the action placeholders.
struct BlockBody: View {
    let block: Block

    static let unavailableText = "Not available this morning."

    var body: some View {
        Group {
            switch block {
            case let .text(_, lines, sources):
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(lines.enumerated()), id: \.offset) { Text($0.element) }
                    SourceLinks(sources: sources)
                }
            case let .number(_, value, unit):
                Text("\(value.formatted(.number.precision(.fractionLength(0...1)))) \(unit)")
                    .font(.system(.title2, design: .monospaced))
            case let .counters(today, week):
                CountersBody(today: today, week: week)
            case let .bar(_, bars):
                BarsBody(bars: bars)
            case let .checklist(_, items):
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        Text("[\(item.checked ? "x" : " ")] \(item.name)")
                    }
                }
            case let .list(_, rows):
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.count.map { "\(row.primary) (\($0))" } ?? row.primary)
                            if let secondary = row.secondary {
                                Text(secondary).font(.system(.caption, design: .monospaced))
                            }
                        }
                    }
                }
            case let .qa(question, answer, realWorld, source):
                VStack(alignment: .leading, spacing: 6) {
                    Text("Q. \(question)")
                    Text("A. \(answer)")
                    Text(realWorld).italic()
                    SourceLinks(sources: [source])
                }
            case let .message(draft):
                Text(draft)
            case let .comic(lesson, panels):
                ComicBody(lesson: lesson, panels: panels)
            case .unavailable, .unsupported:
                Text(Self.unavailableText).italic()
            }
        }
        .font(.system(.body, design: .monospaced))
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct SourceLinks: View {
    let sources: [String]

    var body: some View {
        ForEach(sources, id: \.self) { source in
            if let url = URL(string: source), url.scheme?.hasPrefix("http") == true {
                Link(url.host ?? source, destination: url)
                    .font(.system(.caption, design: .monospaced))
                    .underline()
            }
        }
    }
}

private struct CountersBody: View {
    let today: [String: CounterValue]
    let week: [String: [Int]]

    private static let known = ["ate_out", "buckled", "piano", "stretched"]

    private var keys: [String] {
        Self.known.filter { today[$0] != nil } + today.keys.filter { !Self.known.contains($0) }.sorted()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(keys, id: \.self) { key in
                HStack(alignment: .firstTextBaseline) {
                    Text(Self.label(key)).frame(minWidth: 110, alignment: .leading)
                    Text(Self.value(today[key]))
                    Spacer()
                    if let days = week[key] {
                        Text(days.map(String.init).joined(separator: " "))
                            .font(.system(.caption, design: .monospaced))
                            .accessibilityLabel("Last seven days: \(days.map(String.init).joined(separator: ", "))")
                    }
                }
            }
        }
    }

    static func label(_ key: String) -> String {
        key.replacingOccurrences(of: "_", with: " ").capitalized
    }

    static func value(_ value: CounterValue?) -> String {
        switch value {
        case .count(let n): return "\(n)"
        case .done(let flag): return flag ? "Yes" : "No"
        case nil: return "-"
        }
    }
}

private struct BarsBody: View {
    let bars: [Bar]

    var body: some View {
        let top = max(bars.map(\.value).max() ?? 1, 1)
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(bars.enumerated()), id: \.offset) { _, bar in
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(bar.label)
                        Spacer()
                        Text("\(bar.value.formatted(.number.precision(.fractionLength(0...2)))) \(bar.unit)")
                    }
                    GeometryReader { geo in
                        Rectangle()
                            .frame(width: geo.size.width * CGFloat(max(bar.value, 0) / top))
                    }
                    .frame(height: 8)
                    .overlay(Rectangle().stroke(lineWidth: 1))
                    .accessibilityHidden(true)
                    if let note = bar.note {
                        Text(note).font(.system(.caption, design: .monospaced))
                    }
                }
            }
        }
    }
}

private struct ComicBody: View {
    let lesson: String
    let panels: [ComicPanel]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(Array(panels.enumerated()), id: \.offset) { _, panel in
                    VStack(spacing: 4) {
                        AsyncImage(url: URL(string: panel.imageUrl)) { image in
                            image.resizable().scaledToFit().grayscale(1)
                        } placeholder: {
                            Rectangle().stroke(lineWidth: 1).aspectRatio(1, contentMode: .fit)
                        }
                        Text(panel.caption).font(.system(.caption, design: .monospaced))
                    }
                }
            }
            Text(lesson).italic()
        }
    }
}

/// Shows the backend's filled template. Relative links (paper.css, fonts) resolve against the bundled Paper/ folder.
struct PaperWebView: UIViewRepresentable {
    let html: String

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.isOpaque = false
        view.backgroundColor = .white
        view.accessibilityIdentifier = "daily.paper.web"
        return view
    }

    func updateUIView(_ view: WKWebView, context: Context) {
        guard context.coordinator.loaded != html else { return }
        context.coordinator.loaded = html
        view.loadHTMLString(html, baseURL: Bundle.main.url(forResource: "Paper", withExtension: nil))
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var loaded: String?
    }
}
