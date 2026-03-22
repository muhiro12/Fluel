// swiftlint:disable file_types_order one_declaration_per_file
import FluelLibrary
import MHUI
import SwiftUI

private enum FluelEntryListSupport {
    // Namespace for file name lint alignment.
}

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
    @Environment(\.mhTheme)
    private var theme

    let summary: FluelEntryListSummary

    var body: some View {
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            Text(summary.headline)
                .mhTextStyle(.sectionTitle)

            Text(
                FluelCopy.showingEntries(
                    displayedCount: summary.displayedCount,
                    totalCount: summary.totalCount
                )
            )
            .mhTextStyle(.bodyStrong)

            Text(
                FluelCopy.withNotesCount(summary.noteCount)
            )
            .mhTextStyle(.metadata, colorRole: .secondaryText)

            Text(
                FluelCopy.withPhotosCount(summary.photoCount)
            )
            .mhTextStyle(.metadata, colorRole: .secondaryText)

            Text(
                "\(FluelCopy.sort()): \(summary.sortLabel)"
            )
            .mhTextStyle(.metadata, colorRole: .secondaryText)

            Text(
                "\(FluelCopy.filter()): \(summary.filterLabel)"
            )
            .mhTextStyle(.metadata, colorRole: .secondaryText)
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
        FluelGlassContainer(spacing: theme.fluelInlineSpacing) {
            MHActionGroup {
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
            }
        }
        .mhSurfaceInset()
        .mhSurface(role: .muted)
    }
}
