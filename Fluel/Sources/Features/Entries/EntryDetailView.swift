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
    @State private var editorRoute: EntryEditorRoute?
    @State private var isShowingActionError = false

    let entry: Entry

    var body: some View {
        List {
            Section {
                EntryDetailHeader(entry: entry)
            }

            EntryPhotoDetailSection(photoData: entry.photoData)

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
        .mhListChrome()
        .navigationTitle(entry.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: edit) {
                    Label("Edit", systemImage: "pencil")
                }

                Menu {
                    Button(action: duplicate) {
                        Label("Duplicate", systemImage: "plus.square.on.square")
                    }

                    ShareLink(
                        item: shareSummary.text,
                        subject: Text(shareSummary.subject)
                    ) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(item: $editorRoute) { route in
            if let editedEntry = route.entry {
                EntryEditorView(
                    editing: editedEntry,
                    draft: route.draft,
                    photoData: route.photoData
                )
            } else {
                EntryEditorView(
                    draft: route.draft,
                    photoData: route.photoData
                )
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

    private func edit() {
        presentEditor(entry: entry)
    }

    private func duplicate() {
        presentEditor(entry: nil)
    }

    private func presentEditor(entry editedEntry: Entry?) {
        do {
            editorRoute = try .init(
                entry: editedEntry,
                draft: EntryOperations.makeDraft(from: entry.snapshot),
                photoData: entry.photoData
            )
        } catch {
            isShowingActionError = true
        }
    }

    private func archive() {
        saveAction {
            try EntryStore.archive(
                entry,
                archivedAt: .now,
                in: modelContext
            )
        }
    }

    private func restore() {
        saveAction {
            try EntryStore.restore(
                entry,
                restoredAt: .now,
                in: modelContext
            )
        }
    }

    private func confirmPermanentDelete() {
        isConfirmingPermanentDelete = true
    }

    private func deletePermanently() {
        do {
            try EntryStore.deletePermanently(entry, in: modelContext)
            dismiss()
        } catch {
            isShowingActionError = true
        }
    }

    private func saveAction(_ action: () throws -> Void) {
        do {
            try action()
        } catch {
            isShowingActionError = true
        }
    }
}
