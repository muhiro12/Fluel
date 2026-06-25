//
//  PresetsView.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import SwiftData
import SwiftUI

struct PresetsView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \Preset.title, order: .forward)
    private var presets: [Preset]

    @State private var editorRoute: PresetEditorRoute?
    @State private var entryDraftSheet: PresetEntryDraftSheet?
    @State private var presetPendingDeletion: Preset?
    @State private var isConfirmingDelete = false
    @State private var isShowingActionError = false

    var body: some View {
        List {
            if orderedPresets.isEmpty {
                PresetsEmptyState(create: createPreset)
            } else {
                Section("Presets") {
                    ForEach(orderedPresets) { preset in
                        PresetRowView(
                            preset: preset.snapshot,
                            canEdit: preset.isCustom,
                            use: { use(preset) },
                            edit: { edit(preset) },
                            delete: { confirmDelete(preset) },
                            togglePin: { togglePin(preset) },
                            toggleDefault: { toggleDefault(preset) }
                        )
                    }
                }
            }
        }
        .navigationTitle("Presets")
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
        .onAppear(perform: seedStarterPresets)
    }

    private var orderedPresets: [Preset] {
        let orderedIDs = EntryOperations.orderedPresets(presets.map(\.snapshot)).map(\.id)

        return orderedIDs.compactMap { id in
            presets.first { preset in
                preset.id == id
            }
        }
    }

    private func seedStarterPresets() {
        let existingIDs = Set(presets.map(\.id))
        let missingPresets = EntryOperations.starterPresets().filter { preset in
            !existingIDs.contains(preset.id)
        }

        guard !missingPresets.isEmpty else {
            return
        }

        do {
            for preset in missingPresets {
                modelContext.insert(Preset(preset: preset))
            }

            try modelContext.save()
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
        let usedPreset = EntryOperations.recordUse(of: preset.snapshot, usedAt: .now)
        preset.apply(usedPreset)
        savePresetChange()
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

        presetPendingDeletion = nil
        modelContext.delete(preset)
        savePresetChange()
    }

    private func togglePin(_ preset: Preset) {
        preset.apply(EntryOperations.pin(preset.snapshot, isPinned: !preset.isPinned))
        savePresetChange()
    }

    private func toggleDefault(_ preset: Preset) {
        let defaultID = preset.isDefault ? nil : preset.id
        let updatedPresets = EntryOperations.setDefaultPreset(defaultID, in: presets.map(\.snapshot))

        for updatedPreset in updatedPresets {
            if let matchingPreset = presets.first(where: { candidatePreset in
                candidatePreset.id == updatedPreset.id
            }) {
                matchingPreset.apply(updatedPreset)
            }
        }

        savePresetChange()
    }

    private func savePresetChange() {
        do {
            try modelContext.save()
        } catch {
            isShowingActionError = true
        }
    }
}

#Preview {
    NavigationStack {
        PresetsView()
    }
    .modelContainer(PreviewSampleData.emptyContainer())
}
