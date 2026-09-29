import SwiftUI
import UIKit

@MainActor
struct SourcesView: View {
    @State private var model: SourcesViewModel
    @Environment(\.openURL) private var openURL

    init(model: SourcesViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        List {
            Section {
                ForEach(LinkedAccount.allCases) { account in
                    accountRow(account)
                }
                if let problem = model.problem {
                    Text(problem).foregroundStyle(.red)
                }
            } header: {
                Text("Accounts")
            } footer: {
                Text("You sign in once. The backend keeps the sign-in; the app never stores it.")
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Photos")
                    Text("Your latest five, to send to your parents")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Text(model.photos.label)
                        .font(.system(.caption, design: .monospaced))
                        .accessibilityIdentifier("sources.photos.state")
                }
                photosAction
                VStack(alignment: .leading, spacing: 4) {
                    Text("Contacts")
                    Text("You pick your parents with the system contact picker, so no permission is needed.")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("On this phone")
            }
        }
        .font(.system(.body, design: .monospaced))
        .navigationTitle("Sources")
        .task { await model.refresh() }
        .refreshable { await model.refresh() }
    }

    private func accountRow(_ account: LinkedAccount) -> some View {
        let state = model.state(of: account)
        return HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.title)
                Text("Reads: \(account.reads)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                Text(Self.label(for: state))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(state == .expired ? .red : .primary)
                    .accessibilityIdentifier("sources.\(account.rawValue).state")
            }
            Spacer()
            if model.connecting == account {
                ProgressView()
            } else if let action = Self.actionTitle(for: state) {
                Button(action) { Task { await model.connect(account) } }
                    .buttonStyle(.bordered)
                    .disabled(model.connecting != nil)
            }
        }
    }

    @ViewBuilder
    private var photosAction: some View {
        switch model.photos {
        case .notAsked:
            Button("Allow Photos") { Task { await model.requestPhotos() } }
        case .denied, .limited:
            Button("Open the Settings app") {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            }
        case .granted, .restricted:
            EmptyView()
        }
    }

    static func label(for state: ConnectionState) -> String {
        switch state {
        case .notConnected: return "Not connected"
        case .connected: return "Connected"
        case .expired: return "Sign-in expired"
        case .unavailable(let reason): return reason
        }
    }

    static func actionTitle(for state: ConnectionState) -> String? {
        switch state {
        case .notConnected: return "Connect"
        case .expired: return "Sign in again"
        case .connected, .unavailable: return nil
        }
    }
}

private struct PreviewPhotos: PhotoAccess {
    func current() -> PermissionState { .notAsked }
    func request() async -> PermissionState { .granted }
}

#Preview {
    NavigationStack {
        SourcesView(model: SourcesViewModel(linker: FixtureAccountLinker(), photoAccess: PreviewPhotos()))
    }
}
