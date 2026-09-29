import Foundation
import Observation

/// Holds `AppSettings` and saves every change to UserDefaults at once.
@MainActor
@Observable
final class SettingsStore {
    var settings: AppSettings {
        didSet { if settings != oldValue { save() } }
    }

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let key: String

    init(defaults: UserDefaults = .standard, key: String = "yawnie.settings") {
        self.defaults = defaults
        self.key = key
        if let data = defaults.data(forKey: key), let saved = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = saved
        } else {
            settings = AppSettings()
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: key)
    }
}
