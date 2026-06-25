//
//  PreviewSampleData.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import Foundation
import SwiftData

// swiftlint:disable no_magic_numbers number_separator

@MainActor
enum PreviewSampleData {
    static var sampleEntries: [Entry] {
        [
            Entry(
                title: "This home",
                startDate: date(year: 2021, month: 4, day: 1),
                startPrecision: .year,
                createdAt: date(year: 2026, month: 6, day: 25),
                updatedAt: date(year: 2026, month: 6, day: 25)
            ),
            Entry(
                title: "Notebook",
                startDate: date(year: 2024, month: 9, day: 1),
                startPrecision: .month,
                createdAt: date(year: 2026, month: 6, day: 25),
                updatedAt: date(year: 2026, month: 6, day: 25)
            ),
            Entry(
                title: "Watch",
                startDate: date(year: 2025, month: 12, day: 14),
                startPrecision: .day,
                createdAt: date(year: 2026, month: 6, day: 25),
                updatedAt: date(year: 2026, month: 6, day: 25)
            )
        ]
    }

    static func container() -> ModelContainer {
        let container = emptyContainer()
        let context = container.mainContext

        for entry in sampleEntries {
            context.insert(entry)
        }

        return container
    }

    static func emptyContainer() -> ModelContainer {
        let schema = Schema([Entry.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Could not create preview ModelContainer: \(error)")
        }
    }

    private static func date(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(
            calendar: calendar,
            year: year,
            month: month,
            day: day
        )

        return components.date ?? .now
    }
}

// swiftlint:enable no_magic_numbers number_separator
