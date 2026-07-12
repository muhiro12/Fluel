//
//  PreviewSampleData+Support.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import Foundation
import SwiftData

// swiftlint:disable no_magic_numbers number_separator

extension PreviewSampleData {
    enum Identifier {
        static let thisHome = "10000000-0000-0000-0000-000000000001"
        static let notebook = "10000000-0000-0000-0000-000000000002"
        static let watch = "10000000-0000-0000-0000-000000000003"
        static let deskLamp = "10000000-0000-0000-0000-000000000004"
        static let wallet = "10000000-0000-0000-0000-000000000005"
        static let bag = "10000000-0000-0000-0000-000000000006"
        static let plant = "10000000-0000-0000-0000-000000000007"
        static let longTitle = "10000000-0000-0000-0000-000000000009"
        static let furniturePreset = "20000000-0000-0000-0000-000000000001"
    }

    enum ReferenceDate {
        static let current = date(year: 2026, month: 6, day: 26)
        static let created = date(year: 2026, month: 6, day: 25)
    }

    static func container(
        entries: [Entry],
        presets: [Preset],
        defaultSelections: [PresetDefaultSelection]
    ) -> ModelContainer {
        let modelContainer: ModelContainer

        do {
            modelContainer = try FluelModelContainerFactory.inMemory()
        } catch {
            fatalError("Could not create preview ModelContainer: \(error)")
        }

        let context = modelContainer.mainContext

        for entry in entries {
            context.insert(entry)
        }

        for preset in presets {
            context.insert(preset)
        }

        for defaultSelection in defaultSelections {
            context.insert(defaultSelection)
        }

        do {
            try context.save()
        } catch {
            fatalError("Could not save preview ModelContainer: \(error)")
        }

        return modelContainer
    }

    static func date(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(
            calendar: calendar,
            year: year,
            month: month,
            day: day
        )

        return components.date ?? .now
    }

    static func uuid(_ value: String) -> UUID {
        UUID(uuidString: value) ?? UUID()
    }
}

// swiftlint:enable no_magic_numbers number_separator
