import FluelLibrary
import SwiftData
import SwiftUI
import TipKit

struct ActivityTimelineView: View {
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
        .navigationTitle(FluelCopy.timeline())
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
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: FluelPresentationStyle.sectionSpacing
            ) {
                FluelScreenIntroCard(
                    title: FluelCopy.timeline(),
                    subtitle: FluelCopy.timelineScreenSubtitle()
                )

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
                    .buttonStyle(.borderedProminent)
                }
                .fluelCard(tone: .muted)
            }
            .padding(FluelPresentationStyle.screenPadding)
        }
        .fluelAppBackground()
    }

    private var searchEmptyState: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: FluelPresentationStyle.sectionSpacing
            ) {
                FluelScreenIntroCard(
                    title: FluelCopy.timeline(),
                    subtitle: FluelCopy.timelineScreenSubtitle()
                )

                listHeaderControls

                ContentUnavailableView {
                    Label(
                        FluelCopy.timelineSearchEmptyTitle(),
                        systemImage: "magnifyingglass"
                    )
                } description: {
                    Text(FluelCopy.timelineSearchEmptyBody())
                }
                .fluelCard(tone: .muted)
            }
            .padding(FluelPresentationStyle.screenPadding)
        }
        .fluelAppBackground()
    }

    private var filteredEmptyState: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: FluelPresentationStyle.sectionSpacing
            ) {
                FluelScreenIntroCard(
                    title: FluelCopy.timeline(),
                    subtitle: FluelCopy.timelineScreenSubtitle()
                )

                listHeaderControls

                ContentUnavailableView {
                    Label(
                        FluelCopy.timelineFilterEmptyTitle(),
                        systemImage: "line.3.horizontal.decrease.circle"
                    )
                } description: {
                    Text(FluelCopy.timelineFilterEmptyBody())
                }
                .fluelCard(tone: .muted)
            }
            .padding(FluelPresentationStyle.screenPadding)
        }
        .fluelAppBackground()
    }

    private var timelineList: some View {
        List {
            FluelScreenIntroCard(
                title: FluelCopy.timeline(),
                subtitle: FluelCopy.timelineScreenSubtitle()
            )
            .listRowInsets(.init())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            listHeaderControls
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
        .scrollContentBackground(.hidden)
        .fluelAppBackground()
    }

    private var listHeaderControls: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
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
        .fluelCard(tone: .muted)
    }

    private var filterControls: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
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
    let summary: EntryActivityTimelineSummary
    let activityFilterLabel: String
    let scopeLabel: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(FluelCopy.timelineSummary())
                .fluelSectionTitleStyle()

            Text(
                FluelCopy.timelineShowingActivity(
                    displayedCount: summary.displayedCount,
                    totalCount: summary.totalCount
                )
            )
            .fluelRowTitleStyle()

            Text(
                FluelCopy.timelineMonthsShown(summary.monthCount)
            )
            .fluelMetadataStyle()

            Text(
                FluelCopy.timelineActivityCount(
                    kind: .added,
                    count: summary.addedCount
                )
            )
            .fluelMetadataStyle()

            Text(
                FluelCopy.timelineActivityCount(
                    kind: .updated,
                    count: summary.updatedCount
                )
            )
            .fluelMetadataStyle()

            Text(
                FluelCopy.timelineActivityCount(
                    kind: .archived,
                    count: summary.archivedCount
                )
            )
            .fluelMetadataStyle()

            Text(
                "\(FluelCopy.filter()): \(activityFilterLabel)"
            )
            .fluelMetadataStyle()

            Text(
                "\(FluelCopy.timelineScope()): \(scopeLabel)"
            )
            .fluelMetadataStyle()
        }
        .fluelCard(tone: .muted)
    }
}

private struct TimelineTrendCard: View {
    let trends: [EntryActivityTrendSnapshot]

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(FluelCopy.timelineTrends())
                .fluelSectionTitleStyle()

            VStack(spacing: 0) {
                ForEach(trends, id: \.monthStart) { trend in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(
                            alignment: .firstTextBaseline,
                            spacing: FluelPresentationStyle.inlineSpacing
                        ) {
                            Text(trend.title)
                                .fluelRowTitleStyle()

                            Spacer(minLength: 0)

                            Text(
                                FluelCopy.timelineTrendTotal(
                                    trend.totalCount
                                )
                            )
                            .fluelMetadataStyle()
                        }

                        TimelineTrendBar(trend: trend)

                        GlassEffectContainer(
                            spacing: FluelPresentationStyle.inlineSpacing
                        ) {
                            HStack(
                                spacing: FluelPresentationStyle.inlineSpacing
                            ) {
                                TimelineTrendPill(
                                    label: FluelCopy.timelineActivityCount(
                                        kind: .added,
                                        count: trend.addedCount
                                    ),
                                    kind: .positive
                                )
                                TimelineTrendPill(
                                    label: FluelCopy.timelineActivityCount(
                                        kind: .updated,
                                        count: trend.updatedCount
                                    ),
                                    kind: .accent
                                )
                                TimelineTrendPill(
                                    label: FluelCopy.timelineActivityCount(
                                        kind: .archived,
                                        count: trend.archivedCount
                                    ),
                                    kind: .warning
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
        .fluelCard(tone: .muted)
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
    let kind: FluelBadgeKind

    var body: some View {
        FluelGlassPill(title: label, kind: kind)
    }
}

private struct TimelineMilestoneDigestCard: View {
    let digest: EntryTimelineMilestoneDigest

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(FluelCopy.timelineMilestones())
                .fluelSectionTitleStyle()

            GlassEffectContainer(
                spacing: FluelPresentationStyle.inlineSpacing
            ) {
                HStack(spacing: FluelPresentationStyle.inlineSpacing) {
                    TimelineTrendPill(
                        label: FluelCopy.timelineVisibleEntryCount(
                            digest.visibleEntryCount
                        ),
                        kind: .accent
                    )

                    if digest.approximateCount > 0 {
                        TimelineTrendPill(
                            label: FluelCopy.timelineApproximateMilestones(
                                digest.approximateCount
                            ),
                            kind: .warning
                        )
                    }
                }
            }

            VStack(spacing: 0) {
                ForEach(digest.milestones, id: \.entryID) { milestone in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(
                            alignment: .firstTextBaseline,
                            spacing: FluelPresentationStyle.inlineSpacing
                        ) {
                            Text(milestone.title)
                                .fluelRowTitleStyle()

                            Spacer(minLength: 0)

                            Text(
                                FluelCopy.daysRemaining(
                                    milestone.daysRemaining
                                )
                            )
                            .fluelMetadataStyle()
                        }

                        Text(milestone.milestoneText)
                            .fluelSectionTitleStyle()

                        Text(
                            milestone.milestoneDate.formatted(
                                .dateTime
                                    .month(.abbreviated)
                                    .day()
                            )
                        )
                        .fluelSupportingStyle()

                        if milestone.isApproximate {
                            FluelGlassPill(
                                title: FluelCopy.approximateMilestone(),
                                kind: .warning
                            )
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
        .fluelCard(tone: .muted)
    }
}

private struct TimelineActivityRow: View {
    let activity: EntryActivitySnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(activity.title)
                .fluelRowTitleStyle()

            HStack(spacing: 8) {
                FluelGlassPill(
                    title: FluelCopy.entryActivityKind(activity.kind),
                    kind: activity.kind.fluelBadgeKind
                )

                Text(activityTimestampText)
                    .fluelMetadataStyle()
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
