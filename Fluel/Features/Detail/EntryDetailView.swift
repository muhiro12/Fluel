import FluelLibrary
import MHUI
import SwiftData
import SwiftUI

struct EntryDetailView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var context

    let entry: Entry

    @State private var errorMessage: String?
    @State private var isConfirmingDelete = false
    @State private var isPresentingEditor = false
    @State private var isPresentingDuplicateForm = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 3_600)) { timeline in // swiftlint:disable:this no_magic_numbers
            let snapshot = EntryElapsedSnapshot(
                startComponents: entry.startComponents,
                referenceDate: timeline.date
            )
            let shareText = shareText(referenceDate: timeline.date)

            VStack(alignment: .leading, spacing: 24) {
                EntryDetailQuickActions(
                    entry: entry,
                    shareText: shareText,
                    onDuplicate: presentDuplicateForm,
                    onEdit: presentEditor,
                    onArchive: archive,
                    onRestore: restore
                )
                EntryDetailElapsedSection(snapshot: snapshot)
                EntryDetailDetailsSection(
                    entry: entry,
                    snapshot: snapshot
                )

                if let note = entry.note,
                   note.isEmpty == false {
                    EntryDetailNoteSection(note: note)
                }
            }
            .mhScreen(
                title: Text(entry.title),
                subtitle: Text(
                    EntryFormatting.startLabelText(
                        for: entry.startComponents
                    )
                )
            ) {
                EntryDetailHeaderContent(entry: entry)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EntryDetailMoreMenu(
                        entry: entry,
                        shareText: shareText,
                        onDuplicate: presentDuplicateForm,
                        onEdit: presentEditor,
                        onArchive: archive,
                        onRestore: restore,
                        onDelete: presentDeleteConfirmation
                    )
                }
            }
        }
        .sheet(isPresented: $isPresentingEditor) {
            NavigationStack {
                EntryFormView(
                    mode: .edit(entry)
                )
            }
        }
        .sheet(isPresented: $isPresentingDuplicateForm) {
            NavigationStack {
                EntryFormView(
                    mode: .create,
                    prefilledInput: EntryFormInput(
                        duplicating: entry
                    )
                )
            }
        }
        .confirmationDialog(
            FluelCopy.deleteConfirmationTitle(),
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible
        ) {
            Button(
                FluelCopy.deletePermanently(),
                role: .destructive
            ) {
                delete()
            }

            Button(
                FluelCopy.cancel(),
                role: .cancel
            ) {
                isConfirmingDelete = false
            }
        } message: {
            Text(
                FluelCopy.deleteConfirmationMessage(
                    for: entry.title
                )
            )
        }
        .alert(
            FluelCopy.error(),
            isPresented: Binding(
                get: {
                    errorMessage != nil
                },
                set: { isPresented in
                    if isPresented == false {
                        errorMessage = nil
                    }
                }
            )
        ) {
            Button(FluelCopy.ok(), role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? String())
        }
    }

    private func shareText(
        referenceDate: Date
    ) -> String {
        EntryShareTextFormatter.text(
            for: entry,
            referenceDate: referenceDate
        )
    }

    private func archive() {
        mutationWorkflow.archive(entry: entry)
    }

    private func restore() {
        mutationWorkflow.restore(entry: entry)
    }

    private func delete() {
        mutationWorkflow.delete(entry: entry)
    }

    private func presentEditor() {
        isPresentingEditor = true
    }

    private func presentDuplicateForm() {
        isPresentingDuplicateForm = true
    }

    private func presentDeleteConfirmation() {
        isConfirmingDelete = true
    }
}

private extension EntryDetailView {
    var mutationWorkflow: FluelEntryMutationWorkflow {
        .init(
            context: context,
            onSuccess: {
                dismiss()
            },
            onError: { message in
                errorMessage = message
            }
        )
    }
}

#Preview {
    if let context = try? FluelSampleData.makeSharedContext(),
       let entries = try? context.modelContainer.mainContext.fetch(FetchDescriptor<Entry>()),
       let entry = EntryListOrdering.active(entries).first ?? entries.first {
        NavigationStack {
            EntryDetailView(entry: entry)
        }
        .modelContainer(context.modelContainer)
        .fluelAppStyle()
    } else {
        Text("Failed to load preview")
    }
}
