//
//  PresetStore.swift
//  Fluel
//
//  Created by Codex on 2026/07/12.
//

import FluelLibrary
import Foundation
import SwiftData

enum PresetStore {
    enum SelectionDate {
        static let minimumAdvance: TimeInterval = 0.001
    }

    struct StarterMergeState {
        let isPinned: Bool
        let pinChangedAt: Date?
        let lastUsedAt: Date?
        let createdAt: Date
        let latestUpdatedAt: Date
    }

    struct StarterReconciliationID: Hashable {
        let recordID: UUID
        let title: String
        let symbolName: String
        let startKind: String
        let startValue: Int
        let startPrecision: String
        let note: String?
        let origin: String
        let isPinned: Bool
        let pinChangedAt: Date?
        let lastUsedAt: Date?
        let createdAt: Date
        let updatedAt: Date
    }

    struct ReconciliationID: Hashable {
        let starterRecords: [StarterReconciliationID]
        let latestSelectionID: UUID?
        let selectedPresetID: UUID?
        let selectedPresetExists: Bool
    }

    @MainActor
    static func reconcilePresets(
        _ presets: [Preset],
        defaultSelections: [PresetDefaultSelection],
        in modelContext: ModelContext,
        reconciledAt: Date
    ) throws {
        let starters = EntryOperations.starterPresets()
        let starterIDs = Set(starters.map(\.id))

        try modelContext.performAndSave {
            deleteObsoleteStarterPresets(
                presets,
                retaining: starterIDs,
                in: modelContext
            )

            for starter in starters {
                reconcileStarter(
                    starter,
                    with: presets,
                    in: modelContext,
                    reconciledAt: reconciledAt
                )
            }

            clearDanglingDefaultSelection(
                from: defaultSelections,
                validPresetIDs: validPresetIDs(
                    afterReconciling: presets,
                    starterIDs: starterIDs
                ),
                in: modelContext,
                reconciledAt: reconciledAt
            )
        }
    }

    static func selectedDefaultPresetID(
        from selections: [PresetDefaultSelection]
    ) -> UUID? {
        latestDefaultSelection(from: selections)?.presetID
    }

    static func preset(
        withID id: UUID,
        in presets: [Preset]
    ) -> Preset? {
        canonicalPreset(in: presets.filter { preset in
            preset.id == id
        })
    }

    static func deduplicatedPresets(
        _ presets: [Preset]
    ) -> [Preset] {
        Dictionary(grouping: presets, by: \.id)
            .values
            .compactMap { matchingPresets in
                canonicalPreset(in: matchingPresets)
            }
    }

    static func reconciliationID(
        for presets: [Preset],
        defaultSelections: [PresetDefaultSelection]
    ) -> ReconciliationID {
        let latestSelection = latestDefaultSelection(from: defaultSelections)
        let selectedPresetID = latestSelection?.presetID

        return .init(
            starterRecords: starterReconciliationID(for: presets),
            latestSelectionID: latestSelection?.id,
            selectedPresetID: selectedPresetID,
            selectedPresetExists: selectedPresetID.map { presetID in
                presets.contains { preset in
                    preset.id == presetID
                }
            } ?? true
        )
    }

    private static func starterReconciliationID(
        for presets: [Preset]
    ) -> [StarterReconciliationID] {
        let starterIDs = Set(EntryOperations.starterPresets().map(\.id))

        return presets
            .filter { preset in
                preset.origin == .starter || starterIDs.contains(preset.id)
            }
            .map { preset in
                StarterReconciliationID(
                    recordID: preset.recordID,
                    title: preset.title,
                    symbolName: preset.symbolName,
                    startKind: preset.startKind,
                    startValue: preset.startValue,
                    startPrecision: preset.startPrecision.rawValue,
                    note: preset.note,
                    origin: preset.origin.rawValue,
                    isPinned: preset.isPinned,
                    pinChangedAt: preset.pinChangedAt,
                    lastUsedAt: preset.lastUsedAt,
                    createdAt: preset.createdAt,
                    updatedAt: preset.updatedAt
                )
            }
            .sorted { lhs, rhs in
                lhs.recordID.uuidString < rhs.recordID.uuidString
            }
    }

    static func latestDefaultSelection(
        from selections: [PresetDefaultSelection]
    ) -> PresetDefaultSelection? {
        selections.max(by: selectionPrecedes)
    }

    static func canonicalPreset(
        in presets: [Preset]
    ) -> Preset? {
        presets.min { lhs, rhs in
            lhs.recordID.uuidString < rhs.recordID.uuidString
        }
    }

    private static func selectionPrecedes(
        _ lhs: PresetDefaultSelection,
        _ rhs: PresetDefaultSelection
    ) -> Bool {
        if lhs.selectedAt == rhs.selectedAt {
            return lhs.id.uuidString < rhs.id.uuidString
        }

        return lhs.selectedAt < rhs.selectedAt
    }
}
