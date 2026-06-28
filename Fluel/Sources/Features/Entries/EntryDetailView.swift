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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(
                    item: shareSummary.text,
                    subject: Text(shareSummary.subject)
                ) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
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

    private var shareSummary: EntryShareSummary {
        EntryOperations.entryShareSummary(for: entry.snapshot)
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

#Preview("Entry detail - typical") {
    let preview = PreviewSampleData.detailContainer(title: "Notebook")

    NavigationStack {
        EntryDetailView(entry: preview.entry)
    }
    .mhTheme(.standard)
    .modelContainer(preview.container)
}

#Preview("Entry detail - archived") {
    let preview = PreviewSampleData.detailContainer(title: "Desk lamp")

    NavigationStack {
        EntryDetailView(entry: preview.entry)
    }
    .mhTheme(.standard)
    .modelContainer(preview.container)
}

#Preview("Entry detail - long text, large type") {
    let preview = PreviewSampleData.detailContainer(
        title: "Small wooden chair that moved through different rooms"
    )

    NavigationStack {
        EntryDetailView(entry: preview.entry)
    }
    .mhTheme(.standard)
    .modelContainer(preview.container)
    .dynamicTypeSize(.accessibility2)
}
