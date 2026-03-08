import FluelLibrary
import MHUI
import SwiftData
import SwiftUI
import UIKit

struct EntryDetailView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.mhTheme)
    private var theme
    @Environment(\.modelContext)
    private var context

    let entry: Entry

    @State private var errorMessage: String?
    @State private var isConfirmingDelete = false
    @State private var isPresentingEditor = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 3_600)) { timeline in // swiftlint:disable:this no_magic_numbers
            let snapshot = EntryElapsedSnapshot(
                startComponents: entry.startComponents,
                referenceDate: timeline.date
            )

            VStack(alignment: .leading, spacing: theme.spacing.section) {
                elapsedSection(snapshot: snapshot)
                detailsSection(snapshot: snapshot)

                if let note = entry.note,
                   note.isEmpty == false {
                    noteSection(note)
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
                headerContent
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ShareLink(
                            item: shareText(referenceDate: timeline.date)
                        ) {
                            Label(
                                FluelCopy.share(),
                                systemImage: "square.and.arrow.up"
                            )
                        }

                        Button(
                            FluelCopy.edit()
                        ) {
                            isPresentingEditor = true
                        }

                        if entry.isArchived {
                            Button(
                                FluelCopy.restore()
                            ) {
                                restore()
                            }

                            Button(
                                FluelCopy.delete(),
                                role: .destructive
                            ) {
                                isConfirmingDelete = true
                            }
                        } else {
                            Button(
                                FluelCopy.archive()
                            ) {
                                archive()
                            }
                        }
                    } label: {
                        Label(
                            FluelCopy.more(),
                            systemImage: "ellipsis.circle"
                        )
                    }
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

    @ViewBuilder
    private var headerContent: some View {
        if let image = entryImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 24,
                        style: .continuous
                    )
                )
        }

        if let archivedAt = entry.archivedAt {
            Text(
                EntryFormatting.archivedOnText(
                    archivedAt
                )
            )
            .mhTextStyle(.metadata, colorRole: .secondaryText)
        }
    }

    private func elapsedSection(
        snapshot: EntryElapsedSnapshot
    ) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.control) {
            Text(
                EntryFormatting.primaryElapsedText(
                    for: snapshot
                )
            )
            .font(.system(size: 44, weight: .semibold, design: .rounded))
            .multilineTextAlignment(.leading)

            Text(
                EntryFormatting.detailElapsedText(
                    for: snapshot
                )
            )
            .mhTextStyle(.supporting, colorRole: .secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhSection(
            title: Text(FluelCopy.timeTogetherSectionTitle()),
            supporting: Text(FluelCopy.timeTogetherSectionBody())
        )
    }

    private func detailsSection(
        snapshot: EntryElapsedSnapshot
    ) -> some View {
        VStack(spacing: 0) {
            LabeledContent(
                FluelCopy.started(),
                value: EntryFormatting.startDateText(
                    for: entry.startComponents
                )
            )
            .labeledContentStyle(.mhKeyValue)

            if let startRangeText = EntryFormatting.startRangeText(
                for: entry.startComponents
            ) {
                LabeledContent(
                    FluelCopy.startRange(),
                    value: startRangeText
                )
                .labeledContentStyle(.mhKeyValue)
            }

            LabeledContent(
                FluelCopy.knownAs(),
                value: EntryFormatting.precisionText(
                    for: entry.startPrecision
                )
            )
            .labeledContentStyle(.mhKeyValue)

            LabeledContent(
                FluelCopy.elapsedInFull(),
                value: EntryFormatting.detailElapsedText(
                    for: snapshot
                )
            )
            .labeledContentStyle(.mhKeyValue)

            if let totalMeasureText = EntryFormatting.totalMeasureText(
                for: snapshot
            ) {
                LabeledContent(
                    snapshot.totalDays != nil
                        ? FluelCopy.totalDays()
                        : FluelCopy.totalMonths(),
                    value: totalMeasureText
                )
                .labeledContentStyle(.mhKeyValue)
            }
        }
        .mhGroupedRows()
        .mhSection(
            title: Text(FluelCopy.detailsSectionTitle()),
            supporting: Text(detailsSectionSupportingText)
        )
    }

    private func noteSection(
        _ note: String
    ) -> some View {
        Text(note)
            .frame(maxWidth: .infinity, alignment: .leading)
            .mhTextStyle(.body)
            .mhSection(
                title: Text(FluelCopy.noteSectionTitle()),
                supporting: Text(FluelCopy.notePlaceholder())
            )
    }

    private var detailsSectionSupportingText: String {
        if let archivedAt = entry.archivedAt {
            return EntryFormatting.archivedOnText(archivedAt)
        }

        return FluelCopy.detailsSectionBody()
    }

    private var entryImage: UIImage? {
        guard let photoData = entry.photoData else {
            return nil
        }

        return UIImage(data: photoData)
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
        do {
            try EntryRepository.archive(
                context: context,
                entry: entry
            )
            FluelWidgetReloader.reloadAllTimelines()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func restore() {
        do {
            try EntryRepository.restore(
                context: context,
                entry: entry
            )
            FluelWidgetReloader.reloadAllTimelines()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func delete() {
        do {
            try EntryRepository.delete(
                context: context,
                entry: entry
            )
            FluelWidgetReloader.reloadAllTimelines()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    let context = try! FluelSampleData.makeSharedContext()
    let entries = try! context.modelContainer.mainContext.fetch(FetchDescriptor<Entry>())

    return NavigationStack {
        EntryDetailView(entry: EntryListOrdering.active(entries).first ?? entries[0])
    }
    .modelContainer(context.modelContainer)
    .fluelAppStyle()
}
