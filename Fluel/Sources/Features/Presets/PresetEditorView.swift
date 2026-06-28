//
//  PresetEditorView.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import Foundation
import SwiftData
import SwiftUI

struct PresetEditorView: View {
    private enum Layout {
        static let noteLineLimit = 3...6
    }

    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var title: String
    @State private var note: String
    @State private var symbolOption: PresetSymbolOption
    @State private var startOption: PresetStartOption
    @State private var precision: StartPrecision
    @State private var isShowingSaveError = false

    let preset: Preset?

    var body: some View {
        NavigationStack {
            PresetEditorForm(
                title: $title,
                note: $note,
                symbolOption: $symbolOption,
                startOption: $startOption,
                precision: $precision,
                noteLineLimit: Layout.noteLineLimit
            )
            .navigationTitle(preset == nil ? Text("Create Preset") : Text("Edit Preset"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                PresetEditorToolbar(
                    canSave: canSave,
                    cancel: dismiss.callAsFunction,
                    save: save
                )
            }
            .alert("Preset could not be saved", isPresented: $isShowingSaveError) {
                Button("OK", role: .cancel) {
                    isShowingSaveError = false
                }
            }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(preset: Preset?) {
        let presetSnapshot = preset?.snapshot
        let initialStartOption = presetSnapshot.map { snapshot in
            PresetStartOption.option(for: snapshot.start)
        } ?? .today
        let initialSymbolOption = presetSnapshot.map { snapshot in
            PresetSymbolOption.option(for: snapshot.symbolName)
        } ?? .bookmark

        self.preset = preset
        _title = State(initialValue: presetSnapshot?.title ?? "")
        _note = State(initialValue: presetSnapshot?.note ?? "")
        _symbolOption = State(initialValue: initialSymbolOption)
        _startOption = State(initialValue: initialStartOption)
        _precision = State(
            initialValue: presetSnapshot?.startPrecision ?? initialStartOption.defaultPrecision
        )
    }

    private func save() {
        let snapshot = EntryPreset(
            title: title,
            symbolName: symbolOption.symbolName,
            start: startOption.start,
            startPrecision: precision,
            origin: .custom,
            id: preset?.id ?? UUID(),
            note: note,
            isPinned: preset?.isPinned ?? false,
            isDefault: preset?.isDefault ?? false,
            lastUsedAt: preset?.lastUsedAt
        )

        do {
            if let preset {
                preset.apply(snapshot)
            } else {
                modelContext.insert(Preset(preset: snapshot))
            }

            try modelContext.save()
            dismiss()
        } catch {
            isShowingSaveError = true
        }
    }
}
