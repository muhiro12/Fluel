import FluelLibrary
import MHPlatform
import SwiftData

@MainActor
struct FluelAppBootstrap {
    let appRuntime: MHAppRuntime
    let modelContainer: ModelContainer

    static func live() -> Self {
        let modelContainer: ModelContainer

        do {
            modelContainer = try ModelContainerFactory.shared()
        } catch {
            preconditionFailure("Failed to initialize model container: \(error)")
        }

        return .init(
            appRuntime: .init(
                configuration: FluelAppConfiguration.runtimeConfiguration
            ),
            modelContainer: modelContainer
        )
    }
}
