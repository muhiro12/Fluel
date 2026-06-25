//
//  EntryDetailView.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import MHUI
import SwiftData
import SwiftUI

struct EntryDetailView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var isConfirmingPermanentDelete = false
    @State private var isShowingActionError = false

    let entry: Entry

    var body: some View {
        List {
            EntryDetailHeader(entry: entry)

            EntryStartDetailSection(entry: entry)

            EntryTimeTogetherSection(entry: entry)

            EntryNoteDetailSection(note: entry.note)

            EntryMetadataSection(entry: entry)

            EntryArchiveSection(
                entry: entry,
                archive: archive,
                restore: restore,
                deletePermanently: confirmPermanentDelete
            )
        }
        .navigationTitle(entry.title)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete this archived entry?",
            isPresented: $isConfirmingPermanentDelete,
            titleVisibility: .visible
        ) {
            Button("Delete Permanently", role: .destructive) {
                deletePermanently()
            }

            Button("Keep Entry", role: .cancel) {
                isConfirmingPermanentDelete = false
            }
        } message: {
            Text("This cannot be undone.")
        }
        .alert("Entry could not be updated", isPresented: $isShowingActionError) {
            Button("OK", role: .cancel) {
                isShowingActionError = false
            }
        }
    }

    private func archive() {
        saveAction {
            entry.archive()
        }
    }

    private func restore() {
        saveAction {
            entry.restore()
        }
    }

    private func confirmPermanentDelete() {
        isConfirmingPermanentDelete = true
    }

    private func deletePermanently() {
        do {
            try EntryOperations.validatePermanentDelete(for: entry.snapshot)
            modelContext.delete(entry)
            try modelContext.save()
            dismiss()
        } catch {
            isShowingActionError = true
        }
    }

    private func saveAction(_ action: () -> Void) {
        do {
            action()
            try modelContext.save()
        } catch {
            isShowingActionError = true
        }
    }
}

#Preview {
    NavigationStack {
        EntryDetailView(entry: PreviewSampleData.sampleEntries[1])
    }
    .mhTheme(.standard)
}
