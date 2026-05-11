import Foundation

enum FluelSharedPreferences {
    static let store = UserDefaults(
        suiteName: FluelAppConfiguration.preferencesSuiteName
    ) ?? .standard
}
