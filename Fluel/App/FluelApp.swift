import MHAppRuntime
import MHLogging
import SwiftData
import SwiftUI

@main
struct FluelApp: App {
    private let assembly: FluelAppAssembly
    private let startupLogger = FluelAppLogging.logger(category: "AppStartup")

    var body: some Scene {
        WindowGroup {
            assembly.rootView()
                .modelContainer(assembly.modelContainer)
                .mhAppRuntimeBootstrap(assembly.appBootstrap)
                .fluelAppStyle()
        }
    }

    @MainActor
    init() {
        startupLogger.notice("app startup began")
        FluelTipBootstrap.configureIfNeeded()
        assembly = .init()

        startupLogger.notice("startup dependencies ready")
        startupLogger.notice("startup wiring finished")
    }
}
