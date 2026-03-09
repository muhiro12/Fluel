import FluelLibrary
import MHUI
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
    @Environment(\.mhTheme)
    private var theme
    @EnvironmentObject private var presetStore: EntryPresetStore

    let onAdd: () -> Void
    let onCreateFromPreset: (String) -> Void
    let onShowArchive: () -> Void
    let onShowLicenses: () -> Void

    private var featuredPresets: [EntryPreset] {
        presetStore.suggestedPresets(limit: 4)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(FluelCopy.quickActions())
                .font(.headline)

            MHActionGroup {
                Button(action: onAdd) {
                    Label(
                        FluelCopy.add(),
                        systemImage: "plus.circle"
                    )
                }
                .buttonStyle(.mhPrimary)

                Button(action: onShowArchive) {
                    Label(
                        FluelCopy.archived(),
                        systemImage: "archivebox"
                    )
                }
                .buttonStyle(.mhSecondary)

                Button(action: onShowLicenses) {
                    Label(
                        FluelCopy.licenses(),
                        systemImage: "doc.text"
                    )
                }
                .buttonStyle(.mhSecondary)
            }

            if featuredPresets.isEmpty == false {
                EntryPresetStrip(
                    presets: featuredPresets,
                    selectedPresetID: nil,
                    onSelect: selectPreset
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: .muted)
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
            .buttonStyle(.mhPrimary)
        }
        .mhEmptyStateLayout()
        .mhSurfaceInset()
        .mhSurface(role: .muted)
    }
}

struct DashboardOverviewCard: View {
    private enum Metrics {
        static let metricColumns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
    }

    @Environment(\.mhTheme)
    private var theme

    let snapshot: EntryCollectionSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(FluelCopy.overview())
                .font(.headline)

            LazyVGrid(
                columns: Metrics.metricColumns,
                alignment: .leading,
                spacing: theme.spacing.inline
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: .muted)
    }
}

struct DashboardLeadEntryCard: View {
    @Environment(\.mhTheme)
    private var theme

    let leadEntry: FluelDashboardLeadEntry

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(FluelCopy.leadEntry())
                .font(.headline)

            Text(leadEntry.title)
                .mhRowTitle()

            Text(
                EntryFormatting.startLabelText(
                    for: leadEntry.startComponents
                )
            )
            .mhRowSupporting()

            Text(
                EntryFormatting.primaryElapsedText(
                    for: leadEntry.elapsedSnapshot
                )
            )
            .font(.title2.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface()
    }
}

struct DashboardMilestoneSection: View {
    @Environment(\.mhTheme)
    private var theme

    let milestones: [EntryMilestoneSnapshot]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(FluelCopy.upcomingMilestones())
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(milestones, id: \.entryID) { milestone in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.inline) {
                            Text(milestone.title)
                                .mhRowTitle()

                            Spacer(minLength: 0)

                            Text(
                                FluelCopy.daysRemaining(milestone.daysRemaining)
                            )
                            .mhTextStyle(.metadata, colorRole: .secondaryText)
                        }

                        Text(milestone.milestoneText)
                            .font(.title3.weight(.semibold))

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
                                .mhTextStyle(.metadata, colorRole: .secondaryText)
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: .muted)
    }
}

struct DashboardActivitySection: View {
    @Environment(\.mhTheme)
    private var theme

    let activity: [EntryActivitySnapshot]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(FluelCopy.recentActivity())
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(activity, id: \.entryID) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.inline) {
                            Text(item.title)
                                .mhRowTitle()

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
                            .mhTextStyle(.metadata, colorRole: .secondaryText)
                        }

                        Text(FluelCopy.entryActivityKind(item.kind))
                            .mhRowSupporting()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)

                    if item.entryID != activity.last?.entryID {
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

private struct DashboardMetricTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.title2.weight(.semibold))

            Text(title)
                .mhTextStyle(.supporting, colorRole: .secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background {
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(Color.secondary.opacity(0.08))
        }
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
