import FluelLibrary
import MHUI
import SwiftUI
import UIKit

struct EntryDetailHeaderContent: View {
    let entry: Entry

    var body: some View {
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
                EntryFormatting.archivedOnText(archivedAt)
            )
            .mhTextStyle(.metadata, colorRole: .secondaryText)
        }
    }
}

struct EntryDetailQuickActions: View {
    let entry: Entry
    let shareText: String
    let onDuplicate: () -> Void
    let onEdit: () -> Void
    let onArchive: () -> Void
    let onRestore: () -> Void

    var body: some View {
        MHActionGroup {
            ShareLink(
                item: shareText
            ) {
                Label(
                    FluelCopy.share(),
                    systemImage: "square.and.arrow.up"
                )
            }
            .buttonStyle(.mhSecondary)

            Button(action: onDuplicate) {
                Label(
                    FluelCopy.duplicate(),
                    systemImage: "plus.square.on.square"
                )
            }
            .buttonStyle(.mhSecondary)

            Button(action: onEdit) {
                Label(
                    FluelCopy.edit(),
                    systemImage: "pencil"
                )
            }
            .buttonStyle(.mhSecondary)

            if entry.isArchived {
                Button(action: onRestore) {
                    Label(
                        FluelCopy.restore(),
                        systemImage: "arrow.uturn.backward"
                    )
                }
                .buttonStyle(.mhSecondary)
            } else {
                Button(action: onArchive) {
                    Label(
                        FluelCopy.archive(),
                        systemImage: "archivebox"
                    )
                }
                .buttonStyle(.mhSecondary)
            }
        }
    }
}

struct EntryDetailMoreMenu: View {
    let entry: Entry
    let shareText: String
    let onDuplicate: () -> Void
    let onEdit: () -> Void
    let onArchive: () -> Void
    let onRestore: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Menu {
            ShareLink(item: shareText) {
                Label(
                    FluelCopy.share(),
                    systemImage: "square.and.arrow.up"
                )
            }

            Button(
                FluelCopy.duplicate(),
                action: onDuplicate
            )

            Button(
                FluelCopy.edit(),
                action: onEdit
            )

            if entry.isArchived {
                Button(
                    FluelCopy.restore(),
                    action: onRestore
                )

                Button(
                    FluelCopy.delete(),
                    role: .destructive,
                    action: onDelete
                )
            } else {
                Button(
                    FluelCopy.archive(),
                    action: onArchive
                )
            }
        } label: {
            Label(
                FluelCopy.more(),
                systemImage: "ellipsis.circle"
            )
        }
    }
}

struct EntryDetailElapsedSection: View {
    @Environment(\.mhTheme)
    private var theme

    let snapshot: EntryElapsedSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(
                EntryFormatting.primaryElapsedText(for: snapshot)
            )
            .mhTextStyle(.screenTitle)
            .multilineTextAlignment(.leading)

            Text(
                EntryFormatting.detailElapsedText(for: snapshot)
            )
            .mhTextStyle(.supporting, colorRole: .secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhSection(
            title: Text(FluelCopy.timeTogetherSectionTitle()),
            supporting: Text(FluelCopy.timeTogetherSectionBody())
        )
    }
}

struct EntryDetailDetailsSection: View {
    let entry: Entry
    let snapshot: EntryElapsedSnapshot

    var body: some View {
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

            if let archivedAt = entry.archivedAt {
                LabeledContent(
                    FluelCopy.archivedAfter(),
                    value: EntryFormatting.archivedDurationText(
                        startComponents: entry.startComponents,
                        archivedAt: archivedAt
                    )
                )
                .labeledContentStyle(.mhKeyValue)
            }

            LabeledContent(
                FluelCopy.createdOn(),
                value: EntryFormatting.createdOnText(entry.createdAt)
            )
            .labeledContentStyle(.mhKeyValue)

            LabeledContent(
                FluelCopy.updatedOn(),
                value: EntryFormatting.updatedOnText(entry.updatedAt)
            )
            .labeledContentStyle(.mhKeyValue)
        }
        .mhGroupedRows()
        .mhSection(
            title: Text(FluelCopy.detailsSectionTitle()),
            supporting: Text(detailsSectionSupportingText)
        )
    }
}

struct EntryDetailNoteSection: View {
    let note: String

    var body: some View {
        Text(note)
            .frame(maxWidth: .infinity, alignment: .leading)
            .mhTextStyle(.body)
            .mhSection(
                title: Text(FluelCopy.noteSectionTitle()),
                supporting: Text(FluelCopy.notePlaceholder())
            )
    }
}

private extension EntryDetailHeaderContent {
    var entryImage: UIImage? {
        guard let photoData = entry.photoData else {
            return nil
        }

        return UIImage(data: photoData)
    }
}

private extension EntryDetailDetailsSection {
    var detailsSectionSupportingText: String {
        if let archivedAt = entry.archivedAt {
            return EntryFormatting.archivedOnText(archivedAt)
        }

        return FluelCopy.detailsSectionBody()
    }
}
