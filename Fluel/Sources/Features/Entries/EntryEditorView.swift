//
//  EntryEditorView.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import MHUI
import SwiftData
import SwiftUI

struct EntryEditorView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var draft = EntryDraft()
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

    init() {
        _draft = State(initialValue: EntryDraft())
    }

    init(draft: EntryDraft) {
        _draft = State(initialValue: draft)
    }

    private func cancel() {
        if draft.hasUnsavedContent {
            isConfirmingDiscard = true
        } else {
            dismiss()
        }
    }

    private func save() {
        do {
            let input = try EntryOperations.makeInput(from: draft)

            try modelContext.performAndSave {
                modelContext.insert(Entry(input: input))
            }
            dismiss()
        } catch {
            isShowingSaveError = true
        }
    }
}

#Preview("Add entry - empty") {
    EntryEditorView()
        .modelContainer(PreviewSampleData.emptyContainer())
        .mhTheme(.standard)
}

#Preview("Edit entry - filled") {
    EntryEditorView(draft: PreviewSampleData.filledDraft)
        .modelContainer(PreviewSampleData.emptyContainer())
        .mhTheme(.standard)
}

#Preview("Edit entry - long text, dark") {
    EntryEditorView(draft: PreviewSampleData.longTextDraft)
        .modelContainer(PreviewSampleData.emptyContainer())
        .mhTheme(.standard)
        .preferredColorScheme(.dark)
}
