import Foundation
import MHPlatform
import TipKit

enum FluelTipBootstrap {
    static var isEnabled: Bool {
        let processInfo = ProcessInfo.processInfo

        if processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return false
        }

        return processInfo.arguments.contains("--codex-capture-screen") == false
    }

    static func configureIfNeeded(
        logger: MHLogger
    ) {
        guard isEnabled else {
            logger.notice(
                "TipKit configuration skipped",
                metadata: [
                    "reason": "previewOrCapture"
                ]
            )
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
                "TipKit configuration failed",
                metadata: [
                    "error": error.localizedDescription
                ]
            )
        }
    }

    static func resetTips(
        logger: MHLogger
    ) -> Bool {
        guard isEnabled else {
            logger.warning(
                "TipKit reset skipped",
                metadata: [
                    "reason": "previewOrCapture"
                ]
            )
            return false
        }

        do {
            try Tips.resetDatastore()
            FluelTipState.reset()
            logger.notice("TipKit datastore reset")
            return true
        } catch {
            logger.error(
                "TipKit datastore reset failed",
                metadata: [
                    "error": error.localizedDescription
                ]
            )
            return false
        }
    }
}
