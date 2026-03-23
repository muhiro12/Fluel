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

    @State private var model = TimelineScreenModel()
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

    private var activityFilterBinding: Binding<EntryActivityFilterMode> {
        .init(
            get: {
                model.activityFilter
            },
            set: { newValue in
                model.activityFilter = newValue
            }
        )
    }

    private var scopeFilterBinding: Binding<EntryActivityScopeMode> {
        .init(
            get: {
                model.scopeFilter
            },
            set: { newValue in
                model.scopeFilter = newValue
            }
        )
    }

    private var kindFilteredActivity: [EntryActivitySnapshot] {
        EntryActivityFilter.filter(
            allActivity,
            mode: model.activityFilter
        )
    }

    private var displayedActivity: [EntryActivitySnapshot] {
        EntryActivityScopeFilter.filter(
            kindFilteredActivity,
            mode: model.scopeFilter
        )
    }

    private var searchedActivity: [EntryActivitySnapshot] {
        EntryActivitySearchMatcher.filter(
            displayedActivity,
            matching: model.searchText
        )
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
                model.activityFilter
            ),
            scopeLabel: FluelCopy.entryActivityScopeMode(
                model.scopeFilter
            )
        )
    }

    private var showsTimelineFiltersTip: Bool {
        model.showsTimelineFiltersTip(hasEntries: entries.isEmpty == false)
    }

    private var searchTextBinding: Binding<String> {
        .init(
            get: {
                model.searchText
            },
            set: { newValue in
                model.searchText = newValue
            }
        )
    }

    var body: some View {
        Group {
            if entries.isEmpty {
                emptyState
            } else if displayedActivity.isEmpty {
                filteredEmptyState
            } else if searchedActivity.isEmpty, model.hasActiveSearch {
                searchEmptyState
            } else {
                timelineList
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .searchable(
            text: searchTextBinding,
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
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
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
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
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
                    model.activityFilter
                ),
                scopeLabel: FluelCopy.entryActivityScopeMode(
                    model.scopeFilter
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
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            filterControls

            if model.hasActiveSearch || model.hasActiveFilter {
                FluelEntryListStateActions(
                    showsClearSearch: model.hasActiveSearch,
                    showsClearFilter: model.hasActiveFilter,
                    onClearSearch: clearSearch,
                    onClearFilter: clearFilters
                )
            }
        }
    }

    private var filterControls: some View {
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
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
        model.clearSearch()
    }

    private func clearFilters() {
        model.clearFilters()
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
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
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
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            Text(FluelCopy.timelineTrends())
                .mhTextStyle(.sectionTitle)

            VStack(spacing: 0) {
                ForEach(trends, id: \.monthStart) { trend in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .firstTextBaseline, spacing: theme.fluelInlineSpacing) {
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

                        FluelGlassContainer(spacing: theme.fluelInlineSpacing) {
                            HStack(spacing: theme.fluelInlineSpacing) {
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
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            Text(FluelCopy.timelineMilestones())
                .mhTextStyle(.sectionTitle)

            FluelGlassContainer(spacing: theme.fluelInlineSpacing) {
                HStack(spacing: theme.fluelInlineSpacing) {
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
                        HStack(alignment: .firstTextBaseline, spacing: theme.fluelInlineSpacing) {
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
    .fluelPreviewEnvironment()
    .fluelAppStyle()
}
