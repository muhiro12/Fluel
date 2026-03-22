import FluelLibrary
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
            .fluelMetadataStyle()
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: FluelPresentationStyle.inlineSpacing) {
                ShareLink(
                    item: shareText
                ) {
                    Label(
                        FluelCopy.share(),
                        systemImage: "square.and.arrow.up"
                    )
                }
                .buttonStyle(.glass)

                Button(action: onDuplicate) {
                    Label(
                        FluelCopy.duplicate(),
                        systemImage: "plus.square.on.square"
                    )
                }
                .buttonStyle(.glass)

                Button(action: onEdit) {
                    Label(
                        FluelCopy.edit(),
                        systemImage: "pencil"
                    )
                }
                .buttonStyle(.glass)

                if entry.isArchived {
                    Button(action: onRestore) {
                        Label(
                            FluelCopy.restore(),
                            systemImage: "arrow.uturn.backward"
                        )
                    }
                    .buttonStyle(.glass)
                } else {
                    Button(action: onArchive) {
                        Label(
                            FluelCopy.archive(),
                            systemImage: "archivebox"
                        )
                    }
                    .buttonStyle(.glass)
                }
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
    let snapshot: EntryElapsedSnapshot

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(FluelCopy.timeTogetherSectionTitle())
                .fluelSectionTitleStyle()

            Text(
                EntryFormatting.primaryElapsedText(for: snapshot)
            )
            .fluelDisplayStyle()
            .multilineTextAlignment(.leading)

            Text(
                EntryFormatting.detailElapsedText(for: snapshot)
            )
            .fluelSupportingStyle()

            Text(FluelCopy.timeTogetherSectionBody())
                .fluelMetadataStyle()
        }
        .fluelCard()
    }
}

struct EntryDetailDetailsSection: View {
    let entry: Entry
    let snapshot: EntryElapsedSnapshot

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(FluelCopy.detailsSectionTitle())
                .fluelSectionTitleStyle()

            Text(detailsSectionSupportingText)
                .fluelSupportingStyle()

            VStack(spacing: 12) {
                EntryDetailFieldRow(
                    label: FluelCopy.started(),
                    value: EntryFormatting.startDateText(
                        for: entry.startComponents
                    )
                )

                if let startRangeText = EntryFormatting.startRangeText(
                    for: entry.startComponents
                ) {
                    EntryDetailFieldRow(
                        label: FluelCopy.startRange(),
                        value: startRangeText
                    )
                }

                EntryDetailFieldRow(
                    label: FluelCopy.knownAs(),
                    value: EntryFormatting.precisionText(
                        for: entry.startPrecision
                    )
                )

                EntryDetailFieldRow(
                    label: FluelCopy.elapsedInFull(),
                    value: EntryFormatting.detailElapsedText(
                        for: snapshot
                    )
                )

                if let totalMeasureText = EntryFormatting.totalMeasureText(
                    for: snapshot
                ) {
                    EntryDetailFieldRow(
                        label: snapshot.totalDays != nil
                            ? FluelCopy.totalDays()
                            : FluelCopy.totalMonths(),
                        value: totalMeasureText
                    )
                }

                if let archivedAt = entry.archivedAt {
                    EntryDetailFieldRow(
                        label: FluelCopy.archivedAfter(),
                        value: EntryFormatting.archivedDurationText(
                            startComponents: entry.startComponents,
                            archivedAt: archivedAt
                        )
                    )
                }

                EntryDetailFieldRow(
                    label: FluelCopy.createdOn(),
                    value: EntryFormatting.createdOnText(entry.createdAt)
                )

                EntryDetailFieldRow(
                    label: FluelCopy.updatedOn(),
                    value: EntryFormatting.updatedOnText(entry.updatedAt)
                )
            }
        }
        .fluelCard(tone: .muted)
    }
}

struct EntryDetailNoteSection: View {
    let note: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(FluelCopy.noteSectionTitle())
                .fluelSectionTitleStyle()

            Text(FluelCopy.notePlaceholder())
                .fluelSupportingStyle()

            Text(note)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fluelCard()
    }
}

private struct EntryDetailFieldRow: View {
    let label: String
    let value: String

    var body: some View {
        LabeledContent(label, value: value)
            .font(.subheadline)
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
