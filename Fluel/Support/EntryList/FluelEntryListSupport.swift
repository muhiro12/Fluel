import FluelLibrary
import MHUI
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
        VStack(alignment: .leading, spacing: 12) {
            Text(summary.headline)
                .font(.headline)

            Text(
                FluelCopy.showingEntries(
                    displayedCount: summary.displayedCount,
                    totalCount: summary.totalCount
                )
            )
            .font(.subheadline)

            Text(
                FluelCopy.withNotesCount(summary.noteCount)
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(
                FluelCopy.withPhotosCount(summary.photoCount)
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(
                "\(FluelCopy.sort()): \(summary.sortLabel)"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(
                "\(FluelCopy.filter()): \(summary.filterLabel)"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: .muted)
    }
}

struct FluelEntryListStateActions: View {
    @Environment(\.mhTheme)
    private var theme

    let showsClearSearch: Bool
    let showsClearFilter: Bool
    let onClearSearch: () -> Void
    let onClearFilter: () -> Void

    var body: some View {
        HStack(spacing: theme.spacing.inline) {
            if showsClearSearch {
                Button(
                    FluelCopy.clearSearch(),
                    action: onClearSearch
                )
                .buttonStyle(.mhSecondary)
            }

            if showsClearFilter {
                Button(
                    FluelCopy.clearFilter(),
                    action: onClearFilter
                )
                .buttonStyle(.mhSecondary)
            }

            Spacer(minLength: 0)
        }
        .mhSurfaceInset()
        .mhSurface(role: .muted)
    }
}
