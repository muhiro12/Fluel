import FluelLibrary
import MHUI
import SwiftData
import SwiftUI

struct ActivityTimelineView: View {
    @Environment(\.mhTheme)
    private var theme

    @Query
    private var entries: [Entry]

    @State private var activityFilter = EntryActivityFilterMode.all
    @State private var scopeFilter = EntryActivityScopeMode.recentSixMonths
    @State private var searchText = String()

    let onAdd: () -> Void

    private var sections: [EntryActivityTimelineSection] {
        EntryActivityTimelineSectionQuery.sections(
            activity: searchedActivity,
            limit: max(searchedActivity.count, 1)
        )
    }

    private var entryLookup: [UUID: Entry] {
        Dictionary(
            uniqueKeysWithValues: entries.map { entry in
                (
                    entry.id,
                    entry
                )
            }
        )
    }

    private var allActivity: [EntryActivitySnapshot] {
        EntryActivitySnapshotQuery.recent(
            entries: entries,
            limit: max(entries.count, 1)
        )
    }

    private var kindFilteredActivity: [EntryActivitySnapshot] {
        EntryActivityFilter.filter(
            allActivity,
            mode: activityFilter
        )
    }

    private var displayedActivity: [EntryActivitySnapshot] {
        EntryActivityScopeFilter.filter(
            kindFilteredActivity,
            mode: scopeFilter
        )
    }

    private var searchedActivity: [EntryActivitySnapshot] {
        EntryActivitySearchMatcher.filter(
            displayedActivity,
            matching: searchText
        )
    }

    private var hasActiveSearch: Bool {
        searchText.isEmpty == false
    }

    private var summary: EntryActivityTimelineSummary {
        EntryActivityTimelineSummaryQuery.summary(
            totalActivity: allActivity,
            displayedActivity: searchedActivity
        )
    }

    private var trendSnapshots: [EntryActivityTrendSnapshot] {
        EntryActivityTrendSnapshotQuery.recentMonths(
            activity: searchedActivity
        )
    }

    var body: some View {
        Group {
            if entries.isEmpty {
                emptyState
            } else if displayedActivity.isEmpty {
                filteredEmptyState
            } else if searchedActivity.isEmpty, hasActiveSearch {
                searchEmptyState
            } else {
                timelineList
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchText,
            prompt: FluelCopy.searchTimeline()
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onAdd) {
                    Label(
                        FluelCopy.add(),
                        systemImage: "plus"
                    )
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(
                FluelCopy.timelineEmptyTitle(),
                systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90"
            )
        } description: {
            Text(FluelCopy.timelineEmptyBody())
        } actions: {
            Button(
                FluelCopy.addFirstEntry(),
                action: onAdd
            )
            .buttonStyle(.mhPrimary)
        }
        .mhEmptyStateLayout()
        .mhSurfaceInset()
        .mhSurface(role: .muted)
        .mhScreen(
            title: Text(FluelCopy.timeline()),
            subtitle: Text(FluelCopy.timelineScreenSubtitle())
        )
    }

    private var searchEmptyState: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            filterControls

            ContentUnavailableView {
                Label(
                    FluelCopy.timelineSearchEmptyTitle(),
                    systemImage: "magnifyingglass"
                )
            } description: {
                Text(FluelCopy.timelineSearchEmptyBody())
            }
            .mhEmptyStateLayout()
            .mhSurfaceInset()
            .mhSurface(role: .muted)
        }
        .mhScreen(
            title: Text(FluelCopy.timeline()),
            subtitle: Text(FluelCopy.timelineScreenSubtitle())
        )
    }

    private var filteredEmptyState: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            filterControls

            ContentUnavailableView {
                Label(
                    FluelCopy.timelineFilterEmptyTitle(),
                    systemImage: "line.3.horizontal.decrease.circle"
                )
            } description: {
                Text(FluelCopy.timelineFilterEmptyBody())
            }
            .mhEmptyStateLayout()
            .mhSurfaceInset()
            .mhSurface(role: .muted)
        }
        .mhScreen(
            title: Text(FluelCopy.timeline()),
            subtitle: Text(FluelCopy.timelineScreenSubtitle())
        )
    }

    private var timelineList: some View {
        List {
            TimelineSummaryCard(
                summary: summary,
                activityFilterLabel: FluelCopy.entryActivityFilterMode(
                    activityFilter
                ),
                scopeLabel: FluelCopy.entryActivityScopeMode(
                    scopeFilter
                )
            )
            .listRowInsets(
                .init(
                    top: 0,
                    leading: 0,
                    bottom: 12,
                    trailing: 0
                )
            )
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            if trendSnapshots.isEmpty == false {
                TimelineTrendCard(
                    trends: trendSnapshots
                )
                .listRowInsets(
                    .init(
                        top: 0,
                        leading: 0,
                        bottom: 12,
                        trailing: 0
                    )
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            ForEach(sections, id: \.monthStart) { section in
                Section(section.title) {
                    ForEach(section.items, id: \.entryID) { item in
                        if let entry = entryLookup[item.entryID] {
                            NavigationLink {
                                EntryDetailView(entry: entry)
                            } label: {
                                TimelineActivityRow(activity: item)
                            }
                        } else {
                            TimelineActivityRow(activity: item)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .mhListChrome(
            title: Text(FluelCopy.timeline()),
            subtitle: Text(FluelCopy.timelineScreenSubtitle())
        ) {
            filterControls
        }
    }

    private var filterControls: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            EntryActivityKindFilterBar(
                selection: $activityFilter
            )

            EntryActivityScopeFilterBar(
                selection: $scopeFilter
            )
        }
    }
}

private struct TimelineSummaryCard: View {
    let summary: EntryActivityTimelineSummary
    let activityFilterLabel: String
    let scopeLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(FluelCopy.timelineSummary())
                .font(.headline)

            Text(
                FluelCopy.timelineShowingActivity(
                    displayedCount: summary.displayedCount,
                    totalCount: summary.totalCount
                )
            )
            .font(.subheadline)

            Text(
                FluelCopy.timelineMonthsShown(summary.monthCount)
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(
                FluelCopy.timelineActivityCount(
                    kind: .added,
                    count: summary.addedCount
                )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(
                FluelCopy.timelineActivityCount(
                    kind: .updated,
                    count: summary.updatedCount
                )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(
                FluelCopy.timelineActivityCount(
                    kind: .archived,
                    count: summary.archivedCount
                )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(
                "\(FluelCopy.filter()): \(activityFilterLabel)"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(
                "\(FluelCopy.timelineScope()): \(scopeLabel)"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: .muted)
    }
}

private struct TimelineTrendCard: View {
    @Environment(\.mhTheme)
    private var theme

    let trends: [EntryActivityTrendSnapshot]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(FluelCopy.timelineTrends())
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(trends, id: \.monthStart) { trend in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.inline) {
                            Text(trend.title)
                                .mhRowTitle()

                            Spacer(minLength: 0)

                            Text(
                                FluelCopy.timelineTrendTotal(
                                    trend.totalCount
                                )
                            )
                            .mhTextStyle(.metadata, colorRole: .secondaryText)
                        }

                        TimelineTrendBar(trend: trend)

                        HStack(spacing: 8) {
                            TimelineTrendPill(
                                label: FluelCopy.timelineActivityCount(
                                    kind: .added,
                                    count: trend.addedCount
                                ),
                                color: .green
                            )
                            TimelineTrendPill(
                                label: FluelCopy.timelineActivityCount(
                                    kind: .updated,
                                    count: trend.updatedCount
                                ),
                                color: .blue
                            )
                            TimelineTrendPill(
                                label: FluelCopy.timelineActivityCount(
                                    kind: .archived,
                                    count: trend.archivedCount
                                ),
                                color: .orange
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)

                    if trend.monthStart != trends.last?.monthStart {
                        Divider()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: .muted)
    }
}

private struct TimelineTrendBar: View {
    let trend: EntryActivityTrendSnapshot

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let total = max(Double(trend.totalCount), 1)
            let addedWidth = width * Double(trend.addedCount) / total
            let updatedWidth = width * Double(trend.updatedCount) / total
            let archivedWidth = width * Double(trend.archivedCount) / total

            HStack(spacing: 4) {
                if trend.addedCount > 0 {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.green)
                        .frame(width: max(addedWidth, 10))
                }

                if trend.updatedCount > 0 {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.blue)
                        .frame(width: max(updatedWidth, 10))
                }

                if trend.archivedCount > 0 {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.orange)
                        .frame(width: max(archivedWidth, 10))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 10)
    }
}

private struct TimelineTrendPill: View {
    let label: String
    let color: Color

    var body: some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.12), in: Capsule())
    }
}

private struct TimelineActivityRow: View {
    let activity: EntryActivitySnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(activity.title)
                .mhRowTitle()

            HStack(spacing: 8) {
                Text(
                    FluelCopy.entryActivityKind(activity.kind)
                )
                .font(.caption.weight(.semibold))
                .foregroundStyle(activityColor)

                Text(activityTimestampText)
                    .mhTextStyle(
                        .metadata,
                        colorRole: .secondaryText
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    private var activityColor: Color {
        switch activity.kind {
        case .added:
            return .green
        case .updated:
            return .orange
        case .archived:
            return .secondary
        }
    }

    private var activityTimestampText: String {
        switch activity.kind {
        case .added:
            return EntryFormatting.createdOnText(activity.timestamp)
        case .updated:
            return EntryFormatting.updatedOnText(activity.timestamp)
        case .archived:
            return EntryFormatting.archivedOnText(activity.timestamp)
        }
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    NavigationStack {
        ActivityTimelineView(
            onAdd: {}
        )
    }
    .fluelAppStyle()
}
