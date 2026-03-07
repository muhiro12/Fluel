//
//  FluelApp.swift
//  Fluel
//
//  Created by Hiromu Nakano on 2026/03/07.
//

import SwiftData
import SwiftUI

@main
struct FluelApp: App {
    private let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            seedSampleItemsIfNeeded(in: container)
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

private func seedSampleItemsIfNeeded(
    in container: ModelContainer,
    userDefaults: UserDefaults = .standard
) {
    let seededKey = "fluel.hasSeededPrototypeItems"
    guard userDefaults.bool(forKey: seededKey) == false else {
        return
    }

    let context = container.mainContext
    let descriptor = FetchDescriptor<Item>()

    do {
        if try context.fetch(descriptor).isEmpty == false {
            userDefaults.set(true, forKey: seededKey)
            return
        }

        let calendar = Calendar.autoupdatingCurrent
        let today = Date.now

        let samples = [
            Item(
                name: "この家",
                startDate: calendar.date(
                    byAdding: DateComponents(year: -8, month: -4, day: -12),
                    to: today
                ) ?? today
            ),
            Item(
                name: "財布",
                startDate: calendar.date(
                    byAdding: DateComponents(year: -4, month: -2, day: -6),
                    to: today
                ) ?? today
            ),
            Item(
                name: "革のバッグ",
                startDate: calendar.date(
                    byAdding: DateComponents(year: -1, month: -7, day: -18),
                    to: today
                ) ?? today
            ),
            Item(
                name: "このプロジェクト",
                startDate: calendar.date(
                    byAdding: DateComponents(month: -5, day: -9),
                    to: today
                ) ?? today
            )
        ]

        for item in samples {
            context.insert(item)
        }

        try context.save()
        userDefaults.set(true, forKey: seededKey)
    } catch {
        assertionFailure("Could not seed sample items: \(error)")
    }
}
