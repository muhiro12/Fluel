import MHPlatform
import SwiftData
import SwiftUI

@main
struct FluelApp: App {
    private let assembly: FluelAppAssembly

    var body: some Scene {
        WindowGroup {
            assembly.rootView()
                .modelContainer(assembly.modelContainer)
                .environment(assembly.presetStore)
                .environment(assembly.noticeCenter)
                .environment(assembly.displayPreferences)
                .environment(assembly.logging)
                .environment(assembly.debugSettings)
                .mhAppRuntimeBootstrap(assembly.appBootstrap)
                .fluelNoticePresenter(assembly.noticeCenter)
                .fluelAppStyle()
        }
    }

    @MainActor
    init() {
        let assembly = FluelAppAssembly()
        let startupLogger = assembly.logging.logger(
            category: "AppStartup"
        )

        self.assembly = assembly

        startupLogger.notice(
            "App startup began",
            metadata: assembly.startupMetadata
        )
        FluelTipBootstrap.configureIfNeeded(
            logger: assembly.logging.logger(category: "TipKit")
        )
        startupLogger.notice(
            "Startup dependencies ready",
            metadata: assembly.startupMetadata
        )
        startupLogger.notice(
            "Startup wiring finished",
            metadata: assembly.startupMetadata
        )
    }
}
