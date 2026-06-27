//
//  FluelApp.swift
//  Fluel
//
//  Created by Hiromu Nakano on 2026/06/25.
//

import AppIntents
import Foundation
import MHUI
import SwiftData
import SwiftUI

@main
struct FluelApp: App {
    let previewScreen: PreviewSampleData.Screen?
    let modelContainerResult: Result<ModelContainer, any Error>

    var body: some Scene {
        WindowGroup {
            switch modelContainerResult {
            case .success(let modelContainer):
                rootContent()
                    .mhTheme(.standard)
                    .modelContainer(modelContainer)
            case .failure(let error):
                FluelStartupFailureView(error: error)
                    .mhTheme(.standard)
            }
        }
    }

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        let requestedPreviewScreen = PreviewSampleData.screen(from: arguments)

        previewScreen = requestedPreviewScreen
        modelContainerResult = Result {
            try Self.makeModelContainer(
                arguments: arguments,
                previewScreen: requestedPreviewScreen
            )
        }

        if case .success(let modelContainer) = modelContainerResult {
            Self.registerIntentDependencies(modelContainer)
        }
    }

    private static func makeModelContainer(
        arguments: [String],
        previewScreen: PreviewSampleData.Screen?
    ) throws -> ModelContainer {
        if let previewContainer = PreviewSampleData.container(from: arguments) {
            return previewContainer
        }

        if let previewScreen {
            return PreviewSampleData.container(for: previewScreen.defaultScenario)
        }

        return try FluelModelContainerFactory.production()
    }

    private static func registerIntentDependencies(_ modelContainer: ModelContainer) {
        AppDependencyManager.shared.add {
            modelContainer
        }
        FluelShortcuts.updateAppShortcutParameters()
    }

    @ViewBuilder
    private func rootContent() -> some View {
        if let previewScreen {
            PreviewRootView(screen: previewScreen)
        } else {
            ContentView()
        }
    }
}
