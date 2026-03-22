import FluelLibrary
import SwiftUI

struct FluelEntryListSummary {
    let headline: String
    let displayedCount: Int
    let totalCount: Int
    let noteCount: Int
    let photoCount: Int
    let sortLabel: String
    let filterLabel: String

    init(
        headline: String,
        displayedEntries: [Entry],
        totalEntries: [Entry],
        sortLabel: String,
        filterLabel: String
    ) {
        self.headline = headline
        displayedCount = displayedEntries.count
        totalCount = totalEntries.count
        noteCount = displayedEntries.reduce(into: 0) { partialResult, entry in
            if EntryFormatting.notePreviewText(entry.note) != nil {
                partialResult += 1
            }
        }
        photoCount = displayedEntries.reduce(into: 0) { partialResult, entry in
            if entry.photoData?.isEmpty == false {
                partialResult += 1
            }
        }
        self.sortLabel = sortLabel
        self.filterLabel = filterLabel
    }
}

struct FluelEntryListSummaryCard: View {
    let summary: FluelEntryListSummary

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(summary.headline)
                .fluelSectionTitleStyle()

            Text(
                FluelCopy.showingEntries(
                    displayedCount: summary.displayedCount,
                    totalCount: summary.totalCount
                )
            )
            .fluelRowTitleStyle()

            Text(
                FluelCopy.withNotesCount(summary.noteCount)
            )
            .fluelMetadataStyle()

            Text(
                FluelCopy.withPhotosCount(summary.photoCount)
            )
            .fluelMetadataStyle()

            Text(
                "\(FluelCopy.sort()): \(summary.sortLabel)"
            )
            .fluelMetadataStyle()

            Text(
                "\(FluelCopy.filter()): \(summary.filterLabel)"
            )
            .fluelMetadataStyle()
        }
        .fluelCard(tone: .muted)
    }
}

struct FluelEntryListStateActions: View {
    let showsClearSearch: Bool
    let showsClearFilter: Bool
    let onClearSearch: () -> Void
    let onClearFilter: () -> Void

    var body: some View {
        HStack(spacing: FluelPresentationStyle.inlineSpacing) {
            if showsClearSearch {
                Button(
                    FluelCopy.clearSearch(),
                    action: onClearSearch
                )
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            if showsClearFilter {
                if showsClearSearch {
                    Spacer(minLength: 0)
                }

                Button(
                    FluelCopy.clearFilter(),
                    action: onClearFilter
                )
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .fluelCard(tone: .muted)
    }
}
