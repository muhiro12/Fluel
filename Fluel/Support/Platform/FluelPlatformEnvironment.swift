import FluelLibrary
import Foundation
import MHPlatform
import SwiftData
import SwiftUI

@MainActor
struct FluelPlatformEnvironment {
    let modelContainer: ModelContainer
    let appRuntime: MHAppRuntime
    let preferencesStore: UserDefaults

    static func live() -> Self {
        let modelContainer: ModelContainer

        do {
            modelContainer = try ModelContainerFactory.shared()
        } catch {
            preconditionFailure("Failed to initialize model container: \(error)")
        }

        return make(modelContainer: modelContainer)
    }

    static func preview(
        modelContainer: ModelContainer
    ) -> Self {
        make(modelContainer: modelContainer)
    }
}

private extension FluelPlatformEnvironment {
    static func make(
        modelContainer: ModelContainer
    ) -> Self {
        .init(
            modelContainer: modelContainer,
            appRuntime: .init(
                configuration: FluelAppConfiguration.runtimeConfiguration
            ),
            preferencesStore: FluelSharedPreferences.store
        )
    }
}

extension View {
    func fluelPlatformEnvironment(
        _ environment: FluelPlatformEnvironment
    ) -> some View {
        modelContainer(environment.modelContainer)
            .environment(environment.appRuntime)
    }
}
