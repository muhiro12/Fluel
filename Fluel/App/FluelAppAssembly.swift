import FluelLibrary
import MHPlatform
import SwiftData
import SwiftUI

@MainActor
struct FluelAppAssembly {
    private enum LaunchMode {
        case live
        case capture(CodexCaptureContext)
    }

    private struct ResolvedDependencies {
        let modelContainer: ModelContainer
        let presetStore: EntryPresetStore
        let noticeCenter: FluelNoticeCenter
        let displayPreferences: FluelDisplayPreferencesStore
        let logging: MHLoggingBootstrap
        let debugSettings: FluelDebugSettingsStore
        let appBootstrap: MHAppRuntimeBootstrap
        let launchMode: LaunchMode
    }

    let modelContainer: ModelContainer
    let presetStore: EntryPresetStore
    let noticeCenter: FluelNoticeCenter
    let displayPreferences: FluelDisplayPreferencesStore
    let logging: MHLoggingBootstrap
    let debugSettings: FluelDebugSettingsStore
    let appBootstrap: MHAppRuntimeBootstrap
    private let launchMode: LaunchMode

    var startupMetadata: [String: String] {
        var metadata = [
            "launchMode": launchModeName,
            "diagnosticsEnabled": String(debugSettings.isDiagnosticsEnabled)
        ]

        if case let .capture(context) = launchMode {
            metadata["captureScreen"] = context.screen.rawValue
        }

        return metadata
    }

    private var launchModeName: String {
        switch launchMode {
        case .live:
            return "live"
        case .capture:
            return "capture"
        }
    }

    init() {
        let resolvedDependencies = Self.makeResolvedDependencies()

        modelContainer = resolvedDependencies.modelContainer
        presetStore = resolvedDependencies.presetStore
        noticeCenter = resolvedDependencies.noticeCenter
        displayPreferences = resolvedDependencies.displayPreferences
        logging = resolvedDependencies.logging
        debugSettings = resolvedDependencies.debugSettings
        appBootstrap = resolvedDependencies.appBootstrap
        launchMode = resolvedDependencies.launchMode
    }

    @ViewBuilder
    func rootView() -> some View {
        switch launchMode {
        case .live:
            MainView()
        case let .capture(captureContext):
            CodexCaptureRootView(context: captureContext)
        }
    }
}

private extension FluelAppAssembly {
    private static func makeResolvedDependencies() -> ResolvedDependencies {
        #if DEBUG
        if let captureContext = try? CodexCaptureContext.current() {
            return makeCaptureDependencies(
                for: captureContext
            )
        }
        #endif

        return makeLiveDependencies()
    }

    private static func makeLiveDependencies() -> ResolvedDependencies {
        let runtime = makeRuntime(
            configuration: FluelAppConfiguration.runtimeConfiguration
        )
        let logging = FluelLoggingSupport.makeLogging(
            preferenceStore: runtime.preferenceStore
        )
        let debugSettings = FluelDebugSettingsStore(
            preferenceStore: runtime.preferenceStore,
            logging: logging
        )

        return .init(
            modelContainer: makeLiveModelContainer(
                logger: logging.logger(category: "ModelContainer")
            ),
            presetStore: .init(
                logger: logging.logger(category: "PresetStore")
            ),
            noticeCenter: .init(),
            displayPreferences: .init(
                logger: logging.logger(category: "DisplayPreferences")
            ),
            logging: logging,
            debugSettings: debugSettings,
            appBootstrap: .init(
                runtime: runtime,
                lifecyclePlan: FluelAppConfiguration.runtimeLifecyclePlan
            ),
            launchMode: .live
        )
    }

    #if DEBUG
    private static func makeCaptureDependencies(
        for captureContext: CodexCaptureContext
    ) -> ResolvedDependencies {
        let runtime = makeRuntime(
            configuration: FluelAppConfiguration.captureRuntimeConfiguration
        )
        let loggingDefaultsSelection = FluelLoggingSupport.userDefaultsSelection(
            suiteName: captureContext.preferencesSuiteName
        )
        let diagnosticsEnabledKey = FluelLoggingSupport.makeDiagnosticsEnabledKey(
            defaultSelection: loggingDefaultsSelection
        )
        let logging = FluelLoggingSupport.makeLogging(
            preferenceStore: runtime.preferenceStore,
            defaultSelection: loggingDefaultsSelection
        )
        let debugSettings = FluelDebugSettingsStore(
            preferenceStore: runtime.preferenceStore,
            logging: logging,
            diagnosticsEnabledKey: diagnosticsEnabledKey
        )

        if captureContext.screen == .diagnostics {
            debugSettings.isDiagnosticsEnabled = true
        }

        return .init(
            modelContainer: captureContext.modelContainer,
            presetStore: captureContext.presetStore,
            noticeCenter: .init(),
            displayPreferences: .preview(),
            logging: logging,
            debugSettings: debugSettings,
            appBootstrap: .init(
                runtime: runtime,
                lifecyclePlan: FluelAppConfiguration.runtimeLifecyclePlan
            ),
            launchMode: .capture(captureContext)
        )
    }
    #endif

    static func makeRuntime(
        configuration: MHAppConfiguration
    ) -> MHAppRuntime {
        .init(configuration: configuration)
    }

    static func makeLiveModelContainer(
        logger: MHLogger
    ) -> ModelContainer {
        do {
            return try ModelContainerFactory.shared()
        } catch {
            logger.critical(
                "Model container initialization failed",
                metadata: [
                    "error": error.localizedDescription
                ]
            )
            preconditionFailure("Failed to initialize model container: \(error)")
        }
    }
}
