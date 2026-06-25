//
//  EntryEditorView.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import MHUI
import SwiftData
import SwiftUI

struct EntryEditorView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var draft = EntryEditorDraft()
    @State private var isConfirmingDiscard = false
    @State private var isShowingSaveError = false

    var body: some View {
        NavigationStack {
            EntryEditorForm(draft: $draft)
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                EntryEditorToolbar(
                    canSave: draft.canSave,
                    cancel: cancel,
                    save: save
                )
            }
            .confirmationDialog(
                "Discard this entry?",
                isPresented: $isConfirmingDiscard,
                titleVisibility: .visible
            ) {
                Button("Discard Entry", role: .destructive) {
                    dismiss()
                }

                Button("Keep Editing", role: .cancel) {
                    isConfirmingDiscard = false
                }
            } message: {
                Text("Unsaved changes will be lost.")
            }
            .alert("Entry could not be saved", isPresented: $isShowingSaveError) {
                Button("OK", role: .cancel) {
                    isShowingSaveError = false
                }
            }
            .interactiveDismissDisabled(draft.hasUnsavedContent)
        }
        .mhTheme(.standard)
    }

    private func cancel() {
        if draft.hasUnsavedContent {
            isConfirmingDiscard = true
        } else {
            dismiss()
        }
    }

    private func save() {
        let entry = draft.makeEntry()

        modelContext.insert(entry)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            isShowingSaveError = true
        }
    }
}

#Preview {
    EntryEditorView()
        .modelContainer(PreviewSampleData.emptyContainer())
        .mhTheme(.standard)
}
