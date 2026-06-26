//
//  FluelApp.swift
//  Fluel
//
//  Created by Hiromu Nakano on 2026/06/25.
//

import Foundation
import MHUI
import SwiftData
import SwiftUI

@main
struct FluelApp: App {
    let previewScreen: PreviewSampleData.Screen?
    var sharedModelContainer: ModelContainer

    var body: some Scene {
        WindowGroup {
            if let previewScreen {
                PreviewRootView(screen: previewScreen)
                    .mhTheme(.standard)
            } else {
                ContentView()
                    .mhTheme(.standard)
            }
        }
        .modelContainer(sharedModelContainer)
    }

    init() {
        let arguments = ProcessInfo.processInfo.arguments

        previewScreen = PreviewSampleData.screen(from: arguments)
        sharedModelContainer = Self.makeModelContainer(
            arguments: arguments,
            previewScreen: previewScreen
        )
    }

    private static func makeModelContainer(
        arguments: [String],
        previewScreen: PreviewSampleData.Screen?
    ) -> ModelContainer {
        if let previewContainer = PreviewSampleData.container(from: arguments) {
            return previewContainer
        }

        if let previewScreen {
            return PreviewSampleData.container(for: previewScreen.defaultScenario)
        }

        let schema = Schema([
            Entry.self,
            Preset.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
