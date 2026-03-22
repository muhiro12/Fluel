import FluelLibrary
import SwiftData
import SwiftUI
import TipKit

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

    private let detailQuickActionsTip = FluelTips.DetailQuickActionsTip()

    var body: some View {
        TimelineView(.periodic(from: .now, by: 3_600)) { timeline in // swiftlint:disable:this no_magic_numbers
            let snapshot = EntryElapsedSnapshot(
                startComponents: entry.startComponents,
                referenceDate: timeline.date
            )
            let shareText = shareText(referenceDate: timeline.date)

            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: FluelPresentationStyle.sectionSpacing
                ) {
                    FluelScreenIntroCard(
                        title: nil,
                        subtitle: EntryFormatting.startLabelText(
                            for: entry.startComponents
                        )
                    )

                    EntryDetailHeaderContent(entry: entry)

                    EntryDetailQuickActions(
                        entry: entry,
                        shareText: shareText,
                        onDuplicate: presentDuplicateForm,
                        onEdit: presentEditor,
                        onArchive: archive,
                        onRestore: restore
                    )
                    .popoverTip(
                        showsDetailQuickActionsTip ? detailQuickActionsTip : nil,
                        arrowEdge: .top
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
                .padding(FluelPresentationStyle.screenPadding)
            }
            .fluelAppBackground()
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
        .navigationTitle(entry.title)
        .navigationBarTitleDisplayMode(.inline)
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
        .onDisappear {
            FluelTipState.markDetailQuickActionsLearned()
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
        FluelTipState.markDetailQuickActionsLearned()
        Task {
            await mutationWorkflow.archive(entry: entry)
        }
    }

    private func restore() {
        FluelTipState.markDetailQuickActionsLearned()
        Task {
            await mutationWorkflow.restore(entry: entry)
        }
    }

    private func delete() {
        FluelTipState.markDetailQuickActionsLearned()
        Task {
            await mutationWorkflow.delete(entry: entry)
        }
    }

    private func presentEditor() {
        FluelTipState.markDetailQuickActionsLearned()
        isPresentingEditor = true
    }

    private func presentDuplicateForm() {
        FluelTipState.markDetailQuickActionsLearned()
        isPresentingDuplicateForm = true
    }

    private func presentDeleteConfirmation() {
        isConfirmingDelete = true
    }
}

private extension EntryDetailView {
    var showsDetailQuickActionsTip: Bool {
        FluelTipBootstrap.isEnabled
            && FluelTipState.hasLearnedDetailQuickActions == false
    }

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
        Text(FluelCopy.failedToLoadPreview())
    }
}
