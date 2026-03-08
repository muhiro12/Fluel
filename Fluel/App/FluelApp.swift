import MHLogging
import SwiftUI

@main
struct FluelApp: App {
    private let platformEnvironment: FluelPlatformEnvironment
    private let startupLogger = FluelAppLogging.logger(category: "AppStartup")

    var body: some Scene {
        WindowGroup {
            MainView()
                .fluelPlatformEnvironment(platformEnvironment)
                .fluelAppStyle()
        }
    }

    @MainActor
    init() {
        startupLogger.notice("app startup began")
        platformEnvironment = .live()
        startupLogger.notice("startup dependencies ready")
        startupLogger.notice("startup wiring finished")
    }
}
