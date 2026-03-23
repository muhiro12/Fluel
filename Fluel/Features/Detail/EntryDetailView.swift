// swiftlint:disable closure_body_length
import FluelLibrary
import MHUI
import SwiftData
import SwiftUI
import TipKit

struct EntryDetailView: View {
    private enum Layout {
        static let contentSpacing: CGFloat = 24
    }

    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var context
    @Environment(FluelNoticeCenter.self)
    private var noticeCenter

    let entry: Entry

    @State private var presentationModel = EntryDetailPresentationModel()

    private let detailQuickActionsTip = FluelTips.DetailQuickActionsTip()

    var body: some View {
        TimelineView(.periodic(from: .now, by: 3_600)) { timeline in // swiftlint:disable:this no_magic_numbers
            let snapshot = EntryElapsedSnapshot(
                startComponents: entry.startComponents,
                referenceDate: timeline.date
            )
            let shareText = shareText(referenceDate: timeline.date)

            VStack(alignment: .leading, spacing: Layout.contentSpacing) {
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
        .sheet(item: sheetRouteBinding) { route in
            NavigationStack {
                switch route {
                case .edit:
                    EntryFormView(
                        mode: .edit(entry)
                    )
                case .duplicate:
                    EntryFormView(
                        mode: .create,
                        prefilledInput: EntryFormInput(
                            duplicating: entry
                        )
                    )
                }
            }
        }
        .onDisappear {
            FluelTipState.markDetailQuickActionsLearned()
        }
        .confirmationDialog(
            FluelCopy.deleteConfirmationTitle(),
            isPresented: Binding(
                get: {
                    presentationModel.isConfirmingDelete
                },
                set: { isPresented in
                    if isPresented == false {
                        presentationModel.dismissDeleteConfirmation()
                    }
                }
            ),
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
                presentationModel.dismissDeleteConfirmation()
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
                    presentationModel.errorMessage != nil
                },
                set: { isPresented in
                    if isPresented == false {
                        presentationModel.clearError()
                    }
                }
            )
        ) {
            Button(FluelCopy.ok(), role: .cancel) {
                presentationModel.clearError()
            }
        } message: {
            Text(presentationModel.errorMessage ?? String())
        }
    }

    private var sheetRouteBinding: Binding<EntryDetailPresentationModel.SheetRoute?> {
        .init(
            get: {
                presentationModel.sheetRoute
            },
            set: { newValue in
                presentationModel.sheetRoute = newValue
            }
        )
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
            let result = await mutationWorkflow.archive(entry: entry)
            handleMutationResult(result)
        }
    }

    private func restore() {
        FluelTipState.markDetailQuickActionsLearned()
        Task {
            let result = await mutationWorkflow.restore(entry: entry)
            handleMutationResult(result)
        }
    }

    private func delete() {
        FluelTipState.markDetailQuickActionsLearned()
        Task {
            let result = await mutationWorkflow.delete(entry: entry)
            handleMutationResult(result)
        }
    }

    private func presentEditor() {
        FluelTipState.markDetailQuickActionsLearned()
        presentationModel.presentEdit()
    }

    private func presentDuplicateForm() {
        FluelTipState.markDetailQuickActionsLearned()
        presentationModel.presentDuplicate()
    }

    private func presentDeleteConfirmation() {
        presentationModel.presentDeleteConfirmation()
    }

    private func handleMutationResult(
        _ result: FluelMutationResult
    ) {
        let effect = presentationModel.handle(
            result,
            noticeCenter: noticeCenter
        )

        if effect == .dismiss {
            dismiss()
        }
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
            surface: "EntryDetailView"
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
        .fluelPreviewEnvironment()
        .fluelAppStyle()
    } else {
        Text(FluelCopy.failedToLoadPreview())
    }
}
