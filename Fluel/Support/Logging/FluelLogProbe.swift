#if DEBUG
import MHPlatform

@MainActor
final class FluelLogProbe {
    private let logging = MHLoggingBootstrap(
        captureLevel: .debug,
        subsystem: FluelAppConfiguration.bundleIdentifier
    )

    func logger(
        category: String
    ) -> MHLogger {
        logging.logger(category: category)
    }

    func events() async -> [FluelRecordedLogEvent] {
        await logging.events(in: .current).map(FluelRecordedLogEvent.init)
    }
}
#endif
