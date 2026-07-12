//
//  PreviewSampleData+Presets.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary

// swiftlint:disable no_magic_numbers number_separator

extension PreviewSampleData {
    static var samplePresets: [Preset] {
        var presets = EntryOperations.starterPresets()

        presets = presets.map { preset in
            switch preset.title {
            case "This home":
                EntryOperations.pin(preset, isPinned: true)
            case "Notebook":
                EntryOperations.recordUse(of: preset, usedAt: ReferenceDate.current)
            default:
                preset
            }
        }

        presets.append(.init(
            title: "Furniture",
            symbolName: "chair",
            start: .yearsAgo(4),
            startPrecision: .year,
            origin: .custom,
            id: uuid(Identifier.furniturePreset),
            note: "Can stay through different rooms.",
            isPinned: true,
            lastUsedAt: date(year: 2026, month: 6, day: 20)
        ))

        return presets.map { preset in
            Preset(
                preset: preset,
                createdAt: ReferenceDate.created,
                updatedAt: ReferenceDate.current
            )
        }
    }

    static var sampleDefaultSelections: [PresetDefaultSelection] {
        let defaultID = EntryOperations.starterPresets().first { preset in
            preset.title == "This home"
        }?.id

        return [
            PresetDefaultSelection(
                presetID: defaultID,
                selectedAt: ReferenceDate.current
            )
        ]
    }
}

// swiftlint:enable no_magic_numbers number_separator
