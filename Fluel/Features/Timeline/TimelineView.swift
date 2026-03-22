// swiftlint:disable attributes closure_body_length file_length
// swiftlint:disable file_types_order no_empty_block
// swiftlint:disable no_magic_numbers one_declaration_per_file
// swiftlint:disable type_body_length
import FluelLibrary
import MHUI
import SwiftData
import SwiftUI
import TipKit

private enum TimelineView {
    // Namespace for file name lint alignment.
}

struct ActivityTimelineView: View {
    @Environment(\.mhTheme)
    private var theme

    @Query
    private var entries: [Entry]

    @State private var searchText = String()
    @AppStorage(
        EntryListPreferences.timelineActivityFilter,
        store: EntryListPreferences.store
    )
    private var storedActivityFilter = EntryActivityFilterMode.all.rawValue
    @AppStorage(
        EntryListPreferences.timelineScopeFilter,
        store: EntryListPreferences.store
    )
    private var storedScopeFilter = EntryActivityScopeMode.recentSixMonths.rawValue
    @Namespace private var detailTransition

    let onAdd: () -> Void

    private let timelineFiltersTip = FluelTips.TimelineFiltersTip()

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

    private var activityFilter: EntryActivityFilterMode {
        EntryActivityFilterMode(rawValue: storedActivityFilter) ?? .all
    }

    private var scopeFilter: EntryActivityScopeMode {
        EntryActivityScopeMode(rawValue: storedScopeFilter) ?? .recentSixMonths
    }

    private var activityFilterBinding: Binding<EntryActivityFilterMode> {
        .init(
            get: {
                activityFilter
            },
            set: { newValue in
                storedActivityFilter = newValue.rawValue
                if newValue != .all {
                    FluelTipState.markTimelineFiltersLearned()
                }
            }
        )
    }

    private var scopeFilterBinding: Binding<EntryActivityScopeMode> {
        .init(
            get: {
                scopeFilter
            },
            set: { newValue in
                storedScopeFilter = newValue.rawValue
                if newValue != .recentSixMonths {
                    FluelTipState.markTimelineFiltersLearned()
                }
            }
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

    private var hasActiveFilter: Bool {
        activityFilter != .all || scopeFilter != .recentSixMonths
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

    private var milestoneDigest: EntryTimelineMilestoneDigest {
        EntryTimelineMilestoneDigestQuery.digest(
            entries: entries,
            visibleActivity: searchedActivity
        )
    }

    private var shareText: String {
        EntryActivityTimelineShareTextFormatter.text(
            summary: summary,
            trends: trendSnapshots,
            milestoneDigest: milestoneDigest,
            activityFilterLabel: FluelCopy.entryActivityFilterMode(
                activityFilter
            ),
            scopeLabel: FluelCopy.entryActivityScopeMode(
                scopeFilter
            )
        )
    }

    private var showsTimelineFiltersTip: Bool {
        FluelTipBootstrap.isEnabled
            && FluelTipState.hasLearnedTimelineFilters == false
            && entries.isEmpty == false
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
        .toolbarRole(.editor)
        .searchable(
            text: $searchText,
            prompt: FluelCopy.searchTimeline()
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if searchedActivity.isEmpty == false {
                    ShareLink(item: shareText) {
                        Label(
                            FluelCopy.share(),
                            systemImage: "square.and.arrow.up"
                        )
                    }
                }
            }

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
            listHeaderControls

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
            listHeaderControls

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

            if milestoneDigest.milestoneCount > 0 {
                TimelineMilestoneDigestCard(
                    digest: milestoneDigest
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
                                    .navigationTransition(
                                        .zoom(
                                            sourceID: transitionSourceID(for: item),
                                            in: detailTransition
                                        )
                                    )
                            } label: {
                                TimelineActivityRow(activity: item)
                                    .matchedTransitionSource(
                                        id: transitionSourceID(for: item),
                                        in: detailTransition
                                    )
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
            listHeaderControls
        }
    }

    private var listHeaderControls: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            filterControls

            if hasActiveSearch || hasActiveFilter {
                FluelEntryListStateActions(
                    showsClearSearch: hasActiveSearch,
                    showsClearFilter: hasActiveFilter,
                    onClearSearch: clearSearch,
                    onClearFilter: clearFilters
                )
            }
        }
    }

    private var filterControls: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            EntryActivityKindFilterBar(
                selection: activityFilterBinding
            )

            EntryActivityScopeFilterBar(
                selection: scopeFilterBinding
            )
        }
        .popoverTip(
            showsTimelineFiltersTip ? timelineFiltersTip : nil,
            arrowEdge: .top
        )
    }

    private func clearSearch() {
        searchText = String()
    }

    private func clearFilters() {
        storedActivityFilter = EntryActivityFilterMode.all.rawValue
        storedScopeFilter = EntryActivityScopeMode.recentSixMonths.rawValue
    }

    private func transitionSourceID(
        for activity: EntryActivitySnapshot
    ) -> String {
        "\(activity.entryID.uuidString)-\(activity.kind.rawValue)-\(activity.timestamp.timeIntervalSinceReferenceDate)"
    }
}

private struct TimelineSummaryCard: View {
    @Environment(\.mhTheme)
    private var theme

    let summary: EntryActivityTimelineSummary
    let activityFilterLabel: String
    let scopeLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(FluelCopy.timelineSummary())
                .mhTextStyle(.sectionTitle)

            Text(
                FluelCopy.timelineShowingActivity(
                    displayedCount: summary.displayedCount,
                    totalCount: summary.totalCount
                )
            )
            .mhTextStyle(.bodyStrong)

            Text(
                FluelCopy.timelineMonthsShown(summary.monthCount)
            )
            .mhTextStyle(.metadata, colorRole: .secondaryText)

            Text(
                FluelCopy.timelineActivityCount(
                    kind: .added,
                    count: summary.addedCount
                )
            )
            .mhTextStyle(.metadata, colorRole: .secondaryText)

            Text(
                FluelCopy.timelineActivityCount(
                    kind: .updated,
                    count: summary.updatedCount
                )
            )
            .mhTextStyle(.metadata, colorRole: .secondaryText)

            Text(
                FluelCopy.timelineActivityCount(
                    kind: .archived,
                    count: summary.archivedCount
                )
            )
            .mhTextStyle(.metadata, colorRole: .secondaryText)

            Text(
                "\(FluelCopy.filter()): \(activityFilterLabel)"
            )
            .mhTextStyle(.metadata, colorRole: .secondaryText)

            Text(
                "\(FluelCopy.timelineScope()): \(scopeLabel)"
            )
            .mhTextStyle(.metadata, colorRole: .secondaryText)
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
                .mhTextStyle(.sectionTitle)

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

                        MHGlassContainer(spacing: theme.spacing.inline) {
                            HStack(spacing: theme.spacing.inline) {
                                TimelineTrendPill(
                                    label: FluelCopy.timelineActivityCount(
                                        kind: .added,
                                        count: trend.addedCount
                                    ),
                                    style: .positive
                                )
                                TimelineTrendPill(
                                    label: FluelCopy.timelineActivityCount(
                                        kind: .updated,
                                        count: trend.updatedCount
                                    ),
                                    style: .accent
                                )
                                TimelineTrendPill(
                                    label: FluelCopy.timelineActivityCount(
                                        kind: .archived,
                                        count: trend.archivedCount
                                    ),
                                    style: .warning
                                )
                            }
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
    let style: MHBadgeStyle

    var body: some View {
        Text(label)
            .mhBadge(style: style)
    }
}

private struct TimelineMilestoneDigestCard: View {
    @Environment(\.mhTheme)
    private var theme

    let digest: EntryTimelineMilestoneDigest

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(FluelCopy.timelineMilestones())
                .mhTextStyle(.sectionTitle)

            MHGlassContainer(spacing: theme.spacing.inline) {
                HStack(spacing: theme.spacing.inline) {
                    TimelineTrendPill(
                        label: FluelCopy.timelineVisibleEntryCount(
                            digest.visibleEntryCount
                        ),
                        style: .accent
                    )

                    if digest.approximateCount > 0 {
                        TimelineTrendPill(
                            label: FluelCopy.timelineApproximateMilestones(
                                digest.approximateCount
                            ),
                            style: .warning
                        )
                    }
                }
            }

            VStack(spacing: 0) {
                ForEach(digest.milestones, id: \.entryID) { milestone in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.inline) {
                            Text(milestone.title)
                                .mhRowTitle()

                            Spacer(minLength: 0)

                            Text(
                                FluelCopy.daysRemaining(
                                    milestone.daysRemaining
                                )
                            )
                            .mhTextStyle(.metadata, colorRole: .secondaryText)
                        }

                        Text(milestone.milestoneText)
                            .mhTextStyle(.sectionTitle)

                        Text(
                            milestone.milestoneDate.formatted(
                                .dateTime
                                    .month(.abbreviated)
                                    .day()
                            )
                        )
                        .mhRowSupporting()

                        if milestone.isApproximate {
                            Text(FluelCopy.approximateMilestone())
                                .mhBadge(style: .warning)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)

                    if milestone.entryID != digest.milestones.last?.entryID {
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

private struct TimelineActivityRow: View {
    let activity: EntryActivitySnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(activity.title)
                .mhRowTitle()

            HStack(spacing: 8) {
                Text(FluelCopy.entryActivityKind(activity.kind))
                    .mhBadge(style: activity.kind.fluelBadgeStyle)

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
        ActivityTimelineView {}
    }
    .fluelAppStyle()
}
