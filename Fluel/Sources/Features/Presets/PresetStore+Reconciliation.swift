//
//  PresetStore+Reconciliation.swift
//  Fluel
//
//  Created by Codex on 2026/07/12.
//

import FluelLibrary
import Foundation
import SwiftData

extension PresetStore {
    @MainActor
    static func deleteObsoleteStarterPresets(
        _ presets: [Preset],
        retaining starterIDs: Set<UUID>,
        in modelContext: ModelContext
    ) {
        for preset in presets where preset.origin == .starter && !starterIDs.contains(preset.id) {
            modelContext.delete(preset)
        }
    }

    static func validPresetIDs(
        afterReconciling presets: [Preset],
        starterIDs: Set<UUID>
    ) -> Set<UUID> {
        let retainedPresetIDs: [UUID] = presets.compactMap { preset -> UUID? in
            if preset.origin == .starter,
               !starterIDs.contains(preset.id) {
                return nil
            }

            return preset.id
        }

        return starterIDs.union(retainedPresetIDs)
    }

    @MainActor
    static func clearDanglingDefaultSelection(
        from selections: [PresetDefaultSelection],
        validPresetIDs: Set<UUID>,
        in modelContext: ModelContext,
        reconciledAt: Date
    ) {
        guard let latestSelection = latestDefaultSelection(from: selections),
              let selectedPresetID = latestSelection.presetID,
              !validPresetIDs.contains(selectedPresetID) else {
            return
        }

        let clearedAt = max(
            reconciledAt,
            latestSelection.selectedAt.addingTimeInterval(SelectionDate.minimumAdvance)
        )
        modelContext.insert(PresetDefaultSelection(
            presetID: nil,
            selectedAt: clearedAt
        ))
    }

    @MainActor
    static func reconcileStarter(
        _ starter: EntryPreset,
        with presets: [Preset],
        in modelContext: ModelContext,
        reconciledAt: Date
    ) {
        let matchingPresets = presets.filter { preset in
            preset.id == starter.id
        }

        guard let keeper = canonicalPreset(in: matchingPresets) else {
            modelContext.insert(Preset(
                preset: starter,
                createdAt: reconciledAt,
                updatedAt: reconciledAt
            ))
            return
        }

        let pinSource = pinSource(in: matchingPresets) ?? keeper
        let mergeState = mergeState(for: matchingPresets, pinSource: pinSource)

        keeper.reconcileStarter(
            starter,
            state: mergeState,
            reconciledAt: reconciledAt
        )

        for duplicate in matchingPresets where duplicate !== keeper {
            modelContext.delete(duplicate)
        }
    }

    static func mergeState(
        for presets: [Preset],
        pinSource: Preset
    ) -> StarterMergeState {
        let pinChangedAt = pinSource.pinChangedAt
            ?? (pinSource.isPinned ? pinSource.updatedAt : nil)

        return .init(
            isPinned: pinSource.isPinned,
            pinChangedAt: pinChangedAt,
            lastUsedAt: presets.compactMap(\.lastUsedAt).max(),
            createdAt: presets.map(\.createdAt).min() ?? pinSource.createdAt,
            latestUpdatedAt: presets.map(\.updatedAt).max() ?? pinSource.updatedAt
        )
    }

    static func pinSource(
        in presets: [Preset]
    ) -> Preset? {
        let explicitPinPresets = presets.filter { preset in
            preset.pinChangedAt != nil || preset.isPinned
        }
        let candidates = explicitPinPresets.isEmpty ? presets : explicitPinPresets

        return candidates.max { lhs, rhs in
            let lhsDate = lhs.pinChangedAt ?? lhs.updatedAt
            let rhsDate = rhs.pinChangedAt ?? rhs.updatedAt

            if lhsDate == rhsDate {
                return lhs.recordID.uuidString < rhs.recordID.uuidString
            }

            return lhsDate < rhsDate
        }
    }
}
