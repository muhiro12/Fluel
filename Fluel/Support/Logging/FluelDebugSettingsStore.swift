import MHPlatform
import Observation

@MainActor
@Observable
final class FluelDebugSettingsStore {
    @ObservationIgnored private let preferenceStore: MHPreferenceStore
    @ObservationIgnored private let logging: MHLoggingBootstrap
    @ObservationIgnored private let logger: MHLogger

    var isDiagnosticsEnabled: Bool {
        didSet {
            guard isDiagnosticsEnabled != oldValue else {
                return
            }

            let nextCaptureLevel: MHLogLevel = isDiagnosticsEnabled ? .debug : .warning

            preferenceStore.set(
                isDiagnosticsEnabled,
                for: FluelLoggingSupport.diagnosticsEnabledKey
            )

            if isDiagnosticsEnabled == false {
                logger.notice(
                    "Diagnostics mode updated",
                    metadata: [
                        "isEnabled": String(isDiagnosticsEnabled),
                        "captureLevel": nextCaptureLevel.name
                    ]
                )
            }

            logging.captureLevel = nextCaptureLevel

            if isDiagnosticsEnabled {
                logger.notice(
                    "Diagnostics mode updated",
                    metadata: [
                        "isEnabled": String(isDiagnosticsEnabled),
                        "captureLevel": nextCaptureLevel.name
                    ]
                )
            }
        }
    }

    var captureLevelName: String {
        logging.captureLevel.name
    }

    init(
        preferenceStore: MHPreferenceStore,
        logging: MHLoggingBootstrap,
        logger: MHLogger? = nil
    ) {
        self.preferenceStore = preferenceStore
        self.logging = logging
        self.logger = logger ?? logging.logger(
            category: "DiagnosticsSettings"
        )
        isDiagnosticsEnabled = FluelLoggingSupport.loadDiagnosticsEnabled(
            from: preferenceStore
        )
        self.logging.captureLevel = isDiagnosticsEnabled ? .debug : .warning
    }
}
