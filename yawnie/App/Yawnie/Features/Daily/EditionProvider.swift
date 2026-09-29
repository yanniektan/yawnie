import Foundation

/// What only the phone knows, sent with each edition request.
/// Other features (the comic note, the typed social-hours number) add their fields here.
struct DeviceContext: Encodable, Equatable {
    var day: String
    var timeZone: String
    var preferences: EditionPreferences
}

/// Builds today's edition. The backend client in Services/ conforms to this; the Daily never calls the network itself.
protocol EditionProvider: Sendable {
    /// True for fixture-backed providers, so the screen can say it is showing a sample.
    var isSample: Bool { get }
    func buildEdition(for context: DeviceContext) async throws -> Edition
}

extension EditionProvider {
    var isSample: Bool { false }
}

/// Serves `Paper/sample/edition.sample.json` from the app bundle. Used until the backend client lands.
struct SampleEditionProvider: EditionProvider {
    var bundle: Bundle = .main
    var isSample: Bool { true }

    func buildEdition(for context: DeviceContext) async throws -> Edition {
        try Self.load(from: bundle)
    }

    enum Failure: Error { case missing }

    static func load(from bundle: Bundle = .main) throws -> Edition {
        guard let url = bundle.url(forResource: "edition.sample", withExtension: "json", subdirectory: "Paper/sample") else {
            throw Failure.missing
        }
        return try JSONDecoder().decode(Edition.self, from: Data(contentsOf: url))
    }
}

/// The last edition that built, so the Daily can show it at once while a new one builds.
struct EditionCache: Sendable {
    let fileURL: URL

    static var standard: EditionCache {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return EditionCache(fileURL: folder.appendingPathComponent("Yawnie/last-edition.json"))
    }

    func load() -> Edition? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(Edition.self, from: data)
    }

    func save(_ edition: Edition) throws {
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(edition).write(to: fileURL, options: .atomic)
    }
}
