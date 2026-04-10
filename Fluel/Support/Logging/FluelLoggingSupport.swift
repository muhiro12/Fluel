import Foundation
import MHPlatform

enum FluelLoggingSupport {
    struct PreviewEnvironment {
        let logging: MHLoggingBootstrap
        let debugSettings: FluelDebugSettingsStore
    }

    static let snapshotKey = MHCodablePreferenceKey<[MHLogEvent]>(
        storageKey: "\(FluelAppConfiguration.bundleIdentifier).logging.sessionSnapshot"
    )

    static let diagnosticsEnabledKey = MHBoolPreferenceKey(
        namespace: FluelAppConfiguration.bundleIdentifier,
        name: "logging.diagnosticsEnabled",
        default: false
    )

    static func loadDiagnosticsEnabled(
        from preferenceStore: MHPreferenceStore
    ) -> Bool {
        preferenceStore.bool(for: diagnosticsEnabledKey)
    }

    static func makeLogging(
        preferenceStore: MHPreferenceStore
    ) -> MHLoggingBootstrap {
        .init(
            captureLevel: loadDiagnosticsEnabled(
                from: preferenceStore
            )
            ? .debug
            : .warning,
            subsystem: FluelAppConfiguration.bundleIdentifier,
            snapshotKey: snapshotKey,
            snapshotStore: preferenceStore
        )
    }

    static func makeUserDefaults(
        suiteName: String
    ) -> UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    static func makePreviewEnvironment(
        diagnosticsEnabled: Bool = false,
        suiteName: String = "Fluel.preview.\(UUID().uuidString)"
    ) -> PreviewEnvironment {
        let userDefaults = makeUserDefaults(suiteName: suiteName)
        let preferenceStore = MHPreferenceStore(
            userDefaults: userDefaults
        )

        preferenceStore.set(
            diagnosticsEnabled,
            for: diagnosticsEnabledKey
        )

        let logging = makeLogging(
            preferenceStore: preferenceStore
        )
        let debugSettings = FluelDebugSettingsStore(
            preferenceStore: preferenceStore,
            logging: logging
        )

        return .init(
            logging: logging,
            debugSettings: debugSettings
        )
    }

    static func makePreviewEnvironment(
        suiteName: String
    ) -> PreviewEnvironment {
        let userDefaults = makeUserDefaults(suiteName: suiteName)
        let preferenceStore = MHPreferenceStore(
            userDefaults: userDefaults
        )
        let logging = makeLogging(
            preferenceStore: preferenceStore
        )
        let debugSettings = FluelDebugSettingsStore(
            preferenceStore: preferenceStore,
            logging: logging
        )

        return .init(
            logging: logging,
            debugSettings: debugSettings
        )
    }
}
