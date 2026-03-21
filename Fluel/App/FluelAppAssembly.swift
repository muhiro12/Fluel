import FluelLibrary
import MHAppRuntime
import SwiftData
import SwiftUI

@MainActor
struct FluelAppAssembly {
    private enum LaunchMode {
        case live
        case capture(CodexCaptureContext)
    }

    let modelContainer: ModelContainer
    let presetStore: EntryPresetStore
    let appBootstrap: MHAppRuntimeBootstrap
    private let launchMode: LaunchMode

    init() {
        #if DEBUG
        if let captureContext = try? CodexCaptureContext.current() {
            modelContainer = captureContext.modelContainer
            presetStore = captureContext.presetStore
            appBootstrap = .init(
                configuration: FluelAppConfiguration.captureRuntimeConfiguration,
                lifecyclePlan: FluelAppConfiguration.runtimeLifecyclePlan
            )
            launchMode = .capture(captureContext)
            return
        }
        #endif

        modelContainer = Self.makeLiveModelContainer()
        presetStore = .init()
        appBootstrap = .init(
            configuration: FluelAppConfiguration.runtimeConfiguration,
            lifecyclePlan: FluelAppConfiguration.runtimeLifecyclePlan
        )
        launchMode = .live
    }

    private static func makeLiveModelContainer() -> ModelContainer {
        do {
            return try ModelContainerFactory.shared()
        } catch {
            preconditionFailure("Failed to initialize model container: \(error)")
        }
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
