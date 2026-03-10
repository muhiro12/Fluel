import Foundation
import MHLogging
import TipKit

enum FluelTipBootstrap {
    private static let logger = FluelAppLogging.logger(
        category: "TipKit"
    )

    static var isEnabled: Bool {
        let processInfo = ProcessInfo.processInfo

        if processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return false
        }

        return processInfo.arguments.contains("--codex-capture-screen") == false
    }

    static func configureIfNeeded() {
        guard isEnabled else {
            logger.notice("TipKit disabled for previews or capture")
            return
        }

        do {
            try Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
            logger.notice("TipKit configured")
        } catch let error as TipKitError
                    where error == .tipsDatastoreAlreadyConfigured {
            logger.notice("TipKit already configured")
        } catch {
            logger.error(
                "TipKit configuration failed: \(error.localizedDescription)"
            )
        }
    }

    static func resetTips() {
        guard isEnabled else {
            return
        }

        do {
            try Tips.resetDatastore()
            FluelTipState.reset()
            logger.notice("TipKit datastore reset")
        } catch {
            logger.error(
                "TipKit datastore reset failed: \(error.localizedDescription)"
            )
        }
    }
}
