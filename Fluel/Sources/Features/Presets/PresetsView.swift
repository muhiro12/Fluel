//
//  PresetsView.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import Foundation
import MHUI
import SwiftData
import SwiftUI

struct PresetsView: View {
    @Environment(\.modelContext)
    private var modelContext
    @Environment(\.mhTheme)
    private var theme

    @Query(sort: \Preset.title, order: .forward)
    private var presets: [Preset]

    @Query(sort: \PresetDefaultSelection.selectedAt, order: .reverse)
    private var defaultSelections: [PresetDefaultSelection]

    @State private var editorRoute: PresetEditorRoute?
    @State private var entryDraftSheet: PresetEntryDraftSheet?
    @State private var presetPendingDeletion: Preset?
    @State private var isConfirmingDelete = false
    @State private var isShowingActionError = false

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.section) {
            if let leadPreset = orderedPresets.first {
                PresetLeadSummary(preset: snapshot(for: leadPreset))

                MHGroupedRows {
                    ForEach(orderedPresets) { preset in
                        PresetRowView(
                            preset: snapshot(for: preset),
                            canEdit: preset.isCustom,
                            use: { use(preset) },
                            edit: { edit(preset) },
                            delete: { confirmDelete(preset) },
                            togglePin: { togglePin(preset) },
                            toggleDefault: { toggleDefault(preset) }
                        )
                    }
                }
                .mhSection(
                    "Reusable starting points",
                    supporting: "Use a preset immediately or adjust its reusable details."
                )
            } else {
                PresetsEmptyState(create: createPreset)
            }
        }
        .mhScreen(
            "Presets",
            subtitle: "Familiar ways to begin a new entry."
        )
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: createPreset) {
                    Label("Create Preset", systemImage: "plus")
                }
            }
        }
        .sheet(item: $editorRoute) { route in
            PresetEditorView(preset: route.preset)
        }
        .sheet(item: $entryDraftSheet) { sheet in
            EntryEditorView(draft: sheet.draft)
        }
        .alert("Preset could not be updated", isPresented: $isShowingActionError) {
            Button("OK", role: .cancel) {
                isShowingActionError = false
            }
        }
        .confirmationDialog(
            "Delete this preset?",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible
        ) {
            Button("Delete Preset", role: .destructive, action: deletePendingPreset)
            Button("Cancel", role: .cancel) {
                presetPendingDeletion = nil
            }
        } message: {
            Text("This removes the reusable starting point. Entries already created from it stay unchanged.")
        }
        .task(id: reconciliationID) {
            reconcilePresets()
        }
    }

    private var orderedPresets: [Preset] {
        let deduplicatedPresets = PresetStore.deduplicatedPresets(presets)
        let snapshots = deduplicatedPresets.map { preset in
            snapshot(for: preset)
        }
        let orderedIDs = EntryOperations.orderedPresets(snapshots).map(\.id)

        return orderedIDs.compactMap { id in
            PresetStore.preset(withID: id, in: deduplicatedPresets)
        }
    }

    private var selectedDefaultPresetID: UUID? {
        PresetStore.selectedDefaultPresetID(from: defaultSelections)
    }

    private var reconciliationID: PresetStore.ReconciliationID {
        PresetStore.reconciliationID(
            for: presets,
            defaultSelections: defaultSelections
        )
    }

    private func reconcilePresets() {
        do {
            try PresetStore.reconcilePresets(
                presets,
                defaultSelections: defaultSelections,
                in: modelContext,
                reconciledAt: .now
            )
        } catch {
            isShowingActionError = true
        }
    }

    private func createPreset() {
        editorRoute = .init(preset: nil)
    }

    private func edit(_ preset: Preset) {
        editorRoute = .init(preset: preset)
    }

    private func use(_ preset: Preset) {
        let usedAt = Date.now
        let usedPreset = EntryOperations.recordUse(
            of: snapshot(for: preset),
            usedAt: usedAt
        )

        let didSave = savePresetChange {
            preset.apply(usedPreset, updatedAt: usedAt)
        }

        guard didSave else {
            return
        }

        entryDraftSheet = .init(draft: EntryOperations.makeDraft(from: usedPreset))
    }

    private func confirmDelete(_ preset: Preset) {
        guard preset.isCustom else {
            return
        }

        presetPendingDeletion = preset
        isConfirmingDelete = true
    }

    private func deletePendingPreset() {
        guard let preset = presetPendingDeletion else {
            return
        }

        let deletedAt = Date.now
        let wasDefault = selectedDefaultPresetID == preset.id
        let didSave = savePresetChange {
            if wasDefault {
                modelContext.insert(PresetDefaultSelection(
                    presetID: nil,
                    selectedAt: deletedAt
                ))
            }

            modelContext.delete(preset)
        }

        guard didSave else {
            return
        }

        presetPendingDeletion = nil
    }

    private func togglePin(_ preset: Preset) {
        let changedAt = Date.now
        _ = savePresetChange {
            preset.apply(
                EntryOperations.pin(snapshot(for: preset), isPinned: !preset.isPinned),
                updatedAt: changedAt
            )
        }
    }

    private func toggleDefault(_ preset: Preset) {
        let defaultID = selectedDefaultPresetID == preset.id ? nil : preset.id

        _ = savePresetChange {
            modelContext.insert(PresetDefaultSelection(presetID: defaultID))
        }
    }

    private func snapshot(for preset: Preset) -> EntryPreset {
        preset.snapshot(isDefault: preset.id == selectedDefaultPresetID)
    }

    private func savePresetChange(_ changes: () throws -> Void) -> Bool {
        do {
            try modelContext.performAndSave(changes)
            return true
        } catch {
            isShowingActionError = true
            return false
        }
    }
}

#Preview("Presets - starter presets") {
    NavigationStack {
        PresetsView()
    }
    .mhTheme(.standard)
    .modelContainer(PreviewSampleData.emptyContainer())
}

#Preview("Presets - custom and default") {
    NavigationStack {
        PresetsView()
    }
    .mhTheme(.standard)
    .modelContainer(PreviewSampleData.presetsContainer())
}
