// swiftlint:disable closure_body_length file_types_order
// swiftlint:disable no_magic_numbers one_declaration_per_file
import FluelLibrary
import MHUI
import SwiftUI

private enum DashboardSections {
    // Namespace for file name lint alignment.
}

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
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            Text(FluelCopy.quickActions())
                .mhTextStyle(.sectionTitle)

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
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            Text(FluelCopy.overview())
                .mhTextStyle(.sectionTitle)

            LazyVGrid(
                columns: Metrics.metricColumns,
                alignment: .leading,
                spacing: theme.fluelInlineSpacing
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
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            Text(FluelCopy.leadEntry())
                .mhTextStyle(.sectionTitle)

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
            .mhTextStyle(.screenTitle)
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
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            Text(FluelCopy.upcomingMilestones())
                .mhTextStyle(.sectionTitle)

            VStack(spacing: 0) {
                ForEach(milestones, id: \.entryID) { milestone in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline, spacing: theme.fluelInlineSpacing) {
                            Text(milestone.title)
                                .mhRowTitle()

                            Spacer(minLength: 0)

                            Text(
                                FluelCopy.daysRemaining(milestone.daysRemaining)
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
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            Text(FluelCopy.recentActivity())
                .mhTextStyle(.sectionTitle)

            VStack(spacing: 0) {
                ForEach(activity, id: \.entryID) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline, spacing: theme.fluelInlineSpacing) {
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
                            .mhBadge(style: item.kind.fluelBadgeStyle)
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
                .mhTextStyle(.screenTitle)

            Text(title)
                .mhRowSupporting()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhSurfaceInset()
        .mhSurface()
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
