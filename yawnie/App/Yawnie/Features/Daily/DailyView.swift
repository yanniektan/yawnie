import SwiftUI

/// The Daily: the paper, with the five buttons underneath. Settings and Sources sit in the toolbar.
@MainActor
struct DailyView: View {
    enum Route: Hashable {
        case action(DailyAction)
        case settings
        case sources
    }

    @State private var model: DailyViewModel
    @State private var path: [Route] = []
    @State private var hasLoaded = false
    @Environment(\.scenePhase) private var scenePhase
    private let hooks: DailyHooks

    init(model: DailyViewModel? = nil, hooks: DailyHooks = DailyHooks()) {
        let model = model ?? DailyViewModel(provider: SampleEditionProvider(), settings: SettingsStore())
        _model = State(initialValue: model)
        self.hooks = hooks
    }

    var body: some View {
        NavigationStack(path: $path) {
            page
                .safeAreaInset(edge: .top, spacing: 0) { banner }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    ActionStrip(printEnabled: hooks.print != nil && model.edition != nil, onTap: tap)
                }
                .toolbar { toolbar }
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: Route.self, destination: destination)
        }
        .task {
            guard !hasLoaded else { return }
            hasLoaded = true
            await model.load()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active, hasLoaded { Task { await model.refreshIfStale() } }
        }
    }

    @ViewBuilder
    private var page: some View {
        if let edition = model.edition {
            PaperPageView(edition: edition, sections: model.sections, dateline: model.dateline)
                .refreshable { await model.refresh() }
        } else if model.isBuilding {
            ProgressView("Setting the type…")
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ContentUnavailableView {
                Label("No paper yet", systemImage: "newspaper")
            } description: {
                Text(model.notice ?? "")
            } actions: {
                Button("Try again") { Task { await model.refresh() } }
            }
            .font(.system(.body, design: .monospaced))
        }
    }

    @ViewBuilder
    private var banner: some View {
        let lines = [model.isSample ? "Sample edition. The backend isn't connected yet." : nil, model.edition == nil ? nil : model.notice]
            .compactMap { $0 }
        if !lines.isEmpty {
            Text(lines.joined(separator: "\n"))
                .font(.system(.caption, design: .monospaced))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background { Rectangle().fill(.bar).overlay(Color.yellow.opacity(0.25)) }
                .accessibilityIdentifier("daily.banner")
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button { path.append(.sources) } label: { Label("Sources", systemImage: "link") }
                .accessibilityIdentifier("daily.sources")
        }
        ToolbarItem(placement: .principal) {
            if model.isBuilding && model.edition != nil {
                ProgressView().accessibilityLabel("Updating the paper")
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button { path.append(.settings) } label: { Label("Settings", systemImage: "gearshape") }
                .accessibilityIdentifier("daily.settings")
        }
    }

    private func tap(_ action: DailyAction) {
        if action == .print {
            if let edition = model.edition { hooks.print?(edition) }
        } else {
            path.append(.action(action))
        }
    }

    @ViewBuilder
    private func destination(_ route: Route) -> some View {
        switch route {
        case .action(let action):
            hooks.actionScreen(action, model.result(for: action))
        case .settings:
            SettingsView(model: SettingsViewModel(store: model.settings))
        case .sources:
            SourcesView(model: SourcesViewModel())
        }
    }
}

#Preview("Sample edition") {
    DailyView(model: DailyViewModel(
        provider: SampleEditionProvider(),
        settings: SettingsStore(defaults: UserDefaults(suiteName: "preview.daily")!),
        cache: nil
    ))
}
