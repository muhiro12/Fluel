import MHPlatform

enum FluelAppConfiguration {
    nonisolated static let appName = "Fluel"
    nonisolated static let bundleIdentifier = "com.muhiro12.Fluel"
    nonisolated static let preferencesSuiteName = "com.muhiro12.Fluel.runtime"

    nonisolated static let runtimeConfiguration = makeRuntimeConfiguration(
        nativeAdUnitID: FluelAdMobConfiguration.nativeAdUnitID
    )
    nonisolated static let captureRuntimeConfiguration = makeRuntimeConfiguration(
        nativeAdUnitID: nil
    )

    nonisolated static let runtimeLifecyclePlan = MHAppRuntimeLifecyclePlan(
        skipFirstActivePhase: true
    )

    nonisolated private static func makeRuntimeConfiguration(
        nativeAdUnitID: String?
    ) -> MHAppConfiguration {
        .init(
            subscriptionProductIDs: [],
            subscriptionGroupID: nil,
            nativeAdUnitID: nativeAdUnitID,
            preferencesSuiteName: preferencesSuiteName,
            showsLicenses: true
        )
    }
}
