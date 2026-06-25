//
//  FluelApp.swift
//  Fluel
//
//  Created by Hiromu Nakano on 2026/06/25.
//

import MHUI
import SwiftData
import SwiftUI

@main
struct FluelApp: App {
    var sharedModelContainer: ModelContainer = {
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
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .mhTheme(.standard)
        }
        .modelContainer(sharedModelContainer)
    }
}
