import Foundation
import Observation
import Photos

/// Accounts the backend signs in to. Their tokens live on the backend, never in the app.
enum LinkedAccount: String, CaseIterable, Identifiable, Sendable {
    case gmail, spotify

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gmail: return "Gmail"
        case .spotify: return "Spotify"
        }
    }

    /// What the paper reads from it, shown so the user knows what leaves the phone.
    var reads: String {
        switch self {
        case .gmail: return "Amazon orders, Chase alerts, newsletters and promotions"
        case .spotify: return "Your last 50 plays"
        }
    }
}

enum ConnectionState: Equatable, Sendable {
    case notConnected
    case connected
    /// The token ran out (Google test mode ends them after 7 days). Sign in again.
    case expired
    /// Sign-in can't start, for example because the backend isn't set up yet.
    case unavailable(String)
}

protocol AccountLinking: Sendable {
    func state(of account: LinkedAccount) async -> ConnectionState
    /// Runs the account's sign-in and returns the new state.
    func connect(_ account: LinkedAccount) async throws -> ConnectionState
}

/// Used until the edition backend exposes its sign-in endpoints.
struct BackendNotConfiguredLinker: AccountLinking {
    static let reason = "Sign-in opens once the backend is set up."

    func state(of account: LinkedAccount) async -> ConnectionState { .unavailable(Self.reason) }
    func connect(_ account: LinkedAccount) async throws -> ConnectionState { .unavailable(Self.reason) }
}

/// Fixture states for previews and tests. Never talks to a real account.
struct FixtureAccountLinker: AccountLinking {
    var states: [LinkedAccount: ConnectionState] = [.gmail: .connected, .spotify: .expired]

    func state(of account: LinkedAccount) async -> ConnectionState { states[account] ?? .notConnected }
    func connect(_ account: LinkedAccount) async throws -> ConnectionState { .connected }
}

enum PermissionState: Equatable, Sendable {
    case notAsked, granted, limited, denied, restricted

    init(_ status: PHAuthorizationStatus) {
        switch status {
        case .authorized: self = .granted
        case .limited: self = .limited
        case .denied: self = .denied
        case .restricted: self = .restricted
        case .notDetermined: self = .notAsked
        @unknown default: self = .notAsked
        }
    }

    var label: String {
        switch self {
        case .notAsked: return "Not asked yet"
        case .granted: return "Allowed"
        case .limited: return "Selected photos only"
        case .denied: return "Off. Turn on in the Settings app"
        case .restricted: return "Blocked on this phone"
        }
    }
}

protocol PhotoAccess: Sendable {
    func current() -> PermissionState
    func request() async -> PermissionState
}

/// The parents message shows your latest photos, so Yawnie reads the library.
struct SystemPhotoAccess: PhotoAccess {
    func current() -> PermissionState {
        PermissionState(PHPhotoLibrary.authorizationStatus(for: .readWrite))
    }

    func request() async -> PermissionState {
        PermissionState(await PHPhotoLibrary.requestAuthorization(for: .readWrite))
    }
}

@MainActor
@Observable
final class SourcesViewModel {
    private(set) var accounts: [LinkedAccount: ConnectionState] = [:]
    private(set) var photos: PermissionState
    private(set) var connecting: LinkedAccount?
    private(set) var problem: String?

    @ObservationIgnored private let linker: AccountLinking
    @ObservationIgnored private let photoAccess: PhotoAccess

    init(linker: AccountLinking = BackendNotConfiguredLinker(), photoAccess: PhotoAccess = SystemPhotoAccess()) {
        self.linker = linker
        self.photoAccess = photoAccess
        photos = photoAccess.current()
    }

    func state(of account: LinkedAccount) -> ConnectionState {
        accounts[account] ?? .notConnected
    }

    func refresh() async {
        photos = photoAccess.current()
        for account in LinkedAccount.allCases {
            accounts[account] = await linker.state(of: account)
        }
    }

    func connect(_ account: LinkedAccount) async {
        guard connecting == nil else { return }
        connecting = account
        problem = nil
        defer { connecting = nil }
        do {
            accounts[account] = try await linker.connect(account)
        } catch {
            problem = "\(account.title) sign-in didn't finish. Try again."
        }
    }

    /// Asks for Photos only while the answer is still open. After a no, iOS won't ask again.
    func requestPhotos() async {
        guard photos == .notAsked else { return }
        photos = await photoAccess.request()
    }
}
