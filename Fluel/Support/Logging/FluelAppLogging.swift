import MHPlatform

enum FluelAppLogging {
    nonisolated static let loggerFactory: MHLoggerFactory = {
        let baseFactory = MHLoggerFactory.osLogDefault

        return .init(
            store: baseFactory.store,
            policy: baseFactory.policy,
            subsystem: FluelAppConfiguration.bundleIdentifier
        )
    }()

    nonisolated static func logger(
        category: String,
        source: String = #fileID
    ) -> MHLogger {
        loggerFactory.logger(
            category: category,
            source: source
        )
    }
}
