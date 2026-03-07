import MHPlatform

enum FluelAppConfiguration {
    nonisolated static let appName = "Fluel"
    nonisolated static let bundleIdentifier = "com.muhiro12.Fluel"
    nonisolated static let preferencesSuiteName = "com.muhiro12.Fluel.runtime"

    nonisolated static let runtimeConfiguration = MHAppConfiguration(
        subscriptionProductIDs: [],
        subscriptionGroupID: nil,
        nativeAdUnitID: nil,
        preferencesSuiteName: preferencesSuiteName,
        showsLicenses: true
    )
}
