import Foundation
import MHPlatform

enum FluelLoggingSupport {
    struct PreviewEnvironment {
        let logging: MHLoggingBootstrap
        let debugSettings: FluelDebugSettingsStore
    }

    private static let defaultSelection: MHUserDefaultsSelection = .suite(
        FluelAppConfiguration.preferencesSuiteName
    )

    static let diagnosticsEnabledKey = makeDiagnosticsEnabledKey(
        defaultSelection: defaultSelection
    )

    static func userDefaultsSelection(
        suiteName: String
    ) -> MHUserDefaultsSelection {
        .suite(suiteName)
    }

    private static func snapshotStorageDescriptors(
        defaultSelection: MHUserDefaultsSelection
    ) -> MHLogSnapshotStorageDescriptors {
        .init(
            current: .init(
                storageKey: "\(FluelAppConfiguration.bundleIdentifier).logging.currentSessionSnapshot",
                defaultSelection: defaultSelection
            ),
            previous: .init(
                storageKey: "\(FluelAppConfiguration.bundleIdentifier).logging.previousSessionSnapshot",
                defaultSelection: defaultSelection
            )
        )
    }

    static func makeDiagnosticsEnabledKey(
        defaultSelection: MHUserDefaultsSelection
    ) -> MHBoolPreferenceDescriptor {
        .init(
            storageKey: "\(FluelAppConfiguration.bundleIdentifier).logging.diagnosticsEnabled",
            defaultSelection: defaultSelection,
            default: false
        )
    }

    static func loadDiagnosticsEnabled(
        from preferenceStore: MHPreferenceStore,
        defaultSelection: MHUserDefaultsSelection = defaultSelection
    ) -> Bool {
        preferenceStore.bool(
            for: makeDiagnosticsEnabledKey(
                defaultSelection: defaultSelection
            )
        )
    }

    static func makeLogging(
        preferenceStore: MHPreferenceStore,
        defaultSelection: MHUserDefaultsSelection = defaultSelection
    ) -> MHLoggingBootstrap {
        .init(
            captureLevel: loadDiagnosticsEnabled(
                from: preferenceStore,
                defaultSelection: defaultSelection
            )
            ? .debug
            : .warning,
            subsystem: FluelAppConfiguration.bundleIdentifier,
            snapshotStorageDescriptors: snapshotStorageDescriptors(
                defaultSelection: defaultSelection
            ),
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
