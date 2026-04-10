import MHPlatform

enum FluelAppConfiguration {
    nonisolated static let appName = "Fluel"
    nonisolated static let bundleIdentifier = "com.muhiro12.Fluel"
    nonisolated static let preferencesSuiteName = "com.muhiro12.Fluel.runtime"
    nonisolated static let capturePreferencesSuiteName = "\(preferencesSuiteName).capture"

    nonisolated static let runtimeConfiguration = makeRuntimeConfiguration(
        nativeAdUnitID: FluelAdMobConfiguration.nativeAdUnitID,
        preferencesSuiteName: preferencesSuiteName
    )
    nonisolated static let captureRuntimeConfiguration = makeRuntimeConfiguration(
        nativeAdUnitID: nil,
        preferencesSuiteName: capturePreferencesSuiteName
    )

    nonisolated static let runtimeLifecyclePlan = MHAppRuntimeLifecyclePlan(
        skipFirstActivePhase: true
    )

    nonisolated private static func makeRuntimeConfiguration(
        nativeAdUnitID: String?,
        preferencesSuiteName: String?
    ) -> MHAppConfiguration {
        .init(
            subscriptionProductIDs: [],
            subscriptionGroupID: nil,
            nativeAdUnitID: nativeAdUnitID,
            preferencesSuiteName: preferencesSuiteName,
            showsLicenses: true
        )
    }

    nonisolated static func captureRuntimeConfiguration(
        preferencesSuiteName: String
    ) -> MHAppConfiguration {
        makeRuntimeConfiguration(
            nativeAdUnitID: nil,
            preferencesSuiteName: preferencesSuiteName
        )
    }
}
