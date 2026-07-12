//
//  FluelApp.swift
//  Fluel
//
//  Created by Hiromu Nakano on 2026/06/25.
//

import AppIntents
import Foundation
import MHPlatform
import MHUI
import SwiftData
import SwiftUI

@main
struct FluelApp: App {
    let previewScreen: PreviewSampleData.Screen?
    let platformEnvironmentResult: Result<FluelPlatformEnvironment, any Error>

    var body: some Scene {
        WindowGroup {
            switch platformEnvironmentResult {
            case .success(let platformEnvironment):
                rootContent()
                    .fluelPlatformEnvironment(platformEnvironment)
                    .mhTheme(.standard)
            case .failure:
                FluelStartupFailureView()
                    .mhTheme(.standard)
            }
        }
    }

    @MainActor
    init() {
        let arguments = ProcessInfo.processInfo.arguments
        let requestedPreviewScreen = PreviewSampleData.screen(from: arguments)
        let logging = FluelLogging.makeBootstrap()
        let startupLogger = FluelLogging.logger(
            logging: logging,
            category: FluelLogging.Category.appStartup,
            source: #fileID
        )
        startupLogger.notice("startup.begin")

        previewScreen = requestedPreviewScreen
        platformEnvironmentResult = Result {
            let modelContainer = try Self.makeModelContainer(
                arguments: arguments,
                previewScreen: requestedPreviewScreen
            )

            return FluelPlatformEnvironmentFactory.make(
                modelContainer: modelContainer,
                platformMode: requestedPreviewScreen == nil ? .production : .preview,
                logging: logging
            )
        }

        switch platformEnvironmentResult {
        case .success(let platformEnvironment):
            startupLogger.notice("startup.dependencies_ready")
            Self.registerIntentDependencies(platformEnvironment)
            startupLogger.notice("startup.ready")
        case .failure(let error):
            startupLogger.critical(
                "startup.failed",
                metadata: FluelLogging.errorMetadata(error)
            )
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

    @MainActor
    private static func registerIntentDependencies(
        _ platformEnvironment: FluelPlatformEnvironment
    ) {
        AppDependencyManager.shared.add {
            platformEnvironment.logging
        }
        AppDependencyManager.shared.add {
            platformEnvironment.modelContainer
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
