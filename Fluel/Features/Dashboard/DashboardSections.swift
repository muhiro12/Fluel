import FluelLibrary
import SwiftUI

struct FluelDashboardContent {
    let snapshot: EntryCollectionSnapshot
    let milestones: [EntryMilestoneSnapshot]
    let recentActivity: [EntryActivitySnapshot]
    let leadEntry: FluelDashboardLeadEntry?

    init(
        entries: [Entry],
        referenceDate: Date
    ) {
        snapshot = EntryCollectionSnapshotQuery.snapshot(
            entries: entries,
            referenceDate: referenceDate
        )
        milestones = EntryMilestoneSnapshotQuery.upcomingActiveMilestones(
            entries: entries,
            referenceDate: referenceDate
        )
        recentActivity = EntryActivitySnapshotQuery.recent(entries: entries)

        if let title = snapshot.leadActiveTitle,
           let startComponents = snapshot.leadActiveStartComponents,
           let elapsedSnapshot = snapshot.leadActiveElapsedSnapshot {
            leadEntry = .init(
                title: title,
                startComponents: startComponents,
                elapsedSnapshot: elapsedSnapshot
            )
        } else {
            leadEntry = nil
        }
    }
}

struct FluelDashboardLeadEntry {
    let title: String
    let startComponents: EntryStartComponents
    let elapsedSnapshot: EntryElapsedSnapshot
}

struct DashboardQuickActionsCard: View {
    @Environment(EntryPresetStore.self)
    private var presetStore

    let onAdd: () -> Void
    let onCreateFromPreset: (String) -> Void
    let onShowArchive: () -> Void
    let onShowLicenses: () -> Void

    private var featuredPresets: [EntryPreset] {
        presetStore.suggestedPresets(limit: 4)
    }

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(FluelCopy.quickActions())
                .fluelSectionTitleStyle()

            VStack(alignment: .leading, spacing: FluelPresentationStyle.inlineSpacing) {
                Button(action: onAdd) {
                    Label(
                        FluelCopy.add(),
                        systemImage: "plus.circle"
                    )
                }
                .buttonStyle(.borderedProminent)

                Button(action: onShowArchive) {
                    Label(
                        FluelCopy.archived(),
                        systemImage: "archivebox"
                    )
                }
                .buttonStyle(.bordered)

                Button(action: onShowLicenses) {
                    Label(
                        FluelCopy.licenses(),
                        systemImage: "doc.text"
                    )
                }
                .buttonStyle(.bordered)
            }

            if featuredPresets.isEmpty == false {
                EntryPresetStrip(
                    presets: featuredPresets,
                    selectedPresetID: nil,
                    onSelect: selectPreset
                )
            }
        }
        .fluelCard(tone: .muted)
    }
}

struct DashboardEmptyState: View {
    let onAdd: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(
                FluelCopy.dashboardEmptyTitle(),
                systemImage: "square.grid.2x2"
            )
        } description: {
            Text(FluelCopy.dashboardEmptyBody())
        } actions: {
            Button(
                FluelCopy.addFirstEntry(),
                action: onAdd
            )
            .buttonStyle(.borderedProminent)
        }
        .fluelCard(tone: .muted)
    }
}

struct DashboardOverviewCard: View {
    private enum Metrics {
        static let metricColumns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
    }

    let snapshot: EntryCollectionSnapshot

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(FluelCopy.overview())
                .fluelSectionTitleStyle()

            LazyVGrid(
                columns: Metrics.metricColumns,
                alignment: .leading,
                spacing: FluelPresentationStyle.inlineSpacing
            ) {
                DashboardMetricTile(
                    title: FluelCopy.totalEntriesCount(snapshot.totalCount),
                    value: snapshot.totalCount.formatted()
                )
                DashboardMetricTile(
                    title: FluelCopy.activeEntryCount(snapshot.activeCount),
                    value: snapshot.activeCount.formatted()
                )
                DashboardMetricTile(
                    title: FluelCopy.archivedEntryCount(snapshot.archivedCount),
                    value: snapshot.archivedCount.formatted()
                )
                DashboardMetricTile(
                    title: FluelCopy.withNotesCount(
                        snapshot.activeWithNotesCount + snapshot.archivedWithNotesCount
                    ),
                    value: (
                        snapshot.activeWithNotesCount + snapshot.archivedWithNotesCount
                    ).formatted()
                )
                DashboardMetricTile(
                    title: FluelCopy.withPhotosCount(
                        snapshot.activeWithPhotosCount + snapshot.archivedWithPhotosCount
                    ),
                    value: (
                        snapshot.activeWithPhotosCount + snapshot.archivedWithPhotosCount
                    ).formatted()
                )

                if let mostRecentlyArchivedTitle = snapshot.mostRecentlyArchivedTitle {
                    DashboardMetricTile(
                        title: FluelCopy.recentlyArchivedHighlight(),
                        value: mostRecentlyArchivedTitle
                    )
                }
            }
        }
        .fluelCard(tone: .muted)
    }
}

struct DashboardLeadEntryCard: View {
    let leadEntry: FluelDashboardLeadEntry

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(FluelCopy.leadEntry())
                .fluelSectionTitleStyle()

            Text(leadEntry.title)
                .fluelRowTitleStyle()

            Text(
                EntryFormatting.startLabelText(
                    for: leadEntry.startComponents
                )
            )
            .fluelSupportingStyle()

            Text(
                EntryFormatting.primaryElapsedText(
                    for: leadEntry.elapsedSnapshot
                )
            )
            .fluelDisplayStyle()
        }
        .fluelCard()
    }
}

struct DashboardMilestoneSection: View {
    let milestones: [EntryMilestoneSnapshot]

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(FluelCopy.upcomingMilestones())
                .fluelSectionTitleStyle()

            VStack(spacing: 0) {
                ForEach(milestones, id: \.entryID) { milestone in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(
                            alignment: .firstTextBaseline,
                            spacing: FluelPresentationStyle.inlineSpacing
                        ) {
                            Text(milestone.title)
                                .fluelRowTitleStyle()

                            Spacer(minLength: 0)

                            Text(
                                FluelCopy.daysRemaining(milestone.daysRemaining)
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

                    if milestone.entryID != milestones.last?.entryID {
                        Divider()
                    }
                }
            }
        }
        .fluelCard(tone: .muted)
    }
}

struct DashboardActivitySection: View {
    let activity: [EntryActivitySnapshot]

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(FluelCopy.recentActivity())
                .fluelSectionTitleStyle()

            VStack(spacing: 0) {
                ForEach(activity, id: \.entryID) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(
                            alignment: .firstTextBaseline,
                            spacing: FluelPresentationStyle.inlineSpacing
                        ) {
                            Text(item.title)
                                .fluelRowTitleStyle()

                            Spacer(minLength: 0)

                            Text(
                                item.timestamp.formatted(
                                    .dateTime
                                        .month(.abbreviated)
                                        .day()
                                        .hour()
                                    .minute()
                                )
                            )
                            .fluelMetadataStyle()
                        }

                        FluelGlassPill(
                            title: FluelCopy.entryActivityKind(item.kind),
                            kind: item.kind.fluelBadgeKind
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)

                    if item.entryID != activity.last?.entryID {
                        Divider()
                    }
                }
            }
        }
        .fluelCard(tone: .muted)
    }
}

private struct DashboardMetricTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .fluelMetricStyle()

            Text(title)
                .fluelSupportingStyle()
        }
        .fluelCard()
    }
}

private extension DashboardQuickActionsCard {
    func selectPreset(
        _ preset: EntryPreset
    ) {
        FluelTipState.markPresetSelectionLearned()
        presetStore.markUsed(preset.id)
        onCreateFromPreset(preset.id)
    }
}
