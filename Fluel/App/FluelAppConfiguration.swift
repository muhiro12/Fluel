import MHPlatform

enum FluelAppConfiguration {
    nonisolated static let appName = "Fluel"
    nonisolated static let concept = "An app where time accumulates naturally from a start date"
    nonisolated static let bundleIdentifier = "com.muhiro12.Fluel"
    nonisolated static let preferencesSuiteName = "com.muhiro12.Fluel.runtime"
    nonisolated static let baselineStatusMessage = "MHPlatform baseline is ready"

    nonisolated static let runtimeConfiguration = MHAppConfiguration(
        subscriptionProductIDs: [],
        subscriptionGroupID: nil,
        nativeAdUnitID: nil,
        preferencesSuiteName: preferencesSuiteName,
        showsLicenses: true
    )
}
