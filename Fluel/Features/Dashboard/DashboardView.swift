import FluelLibrary
import MHUI
import SwiftData
import SwiftUI

struct DashboardView: View {
    private enum Metrics {
        static let metricColumns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
    }

    @Environment(\.mhTheme)
    private var theme

    @Query
    private var entries: [Entry]
    @AppStorage(
        DisplayPreferences.showsDashboardHighlights,
        store: DisplayPreferences.store
    )
    private var showsDashboardHighlights = true

    let onAdd: () -> Void
    let onShowArchive: () -> Void
    let onShowLicenses: () -> Void

    var body: some View {
        TimelineView(.periodic(from: .now, by: 3_600)) { timeline in // swiftlint:disable:this no_magic_numbers
            let snapshot = EntryCollectionSnapshotQuery.snapshot(
                entries: entries,
                referenceDate: timeline.date
            )
            let milestones = EntryMilestoneSnapshotQuery.upcomingActiveMilestones(
                entries: entries,
                referenceDate: timeline.date
            )
            let recentActivity = EntryActivitySnapshotQuery.recent(
                entries: entries
            )

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.section) {
                    quickActions

                    if snapshot.totalCount == 0 {
                        emptyState
                    } else {
                        overviewCard(snapshot)

                        if let leadEntryCard = leadEntryCard(snapshot) {
                            leadEntryCard
                        }

                        if showsDashboardHighlights,
                           milestones.isEmpty == false {
                            milestoneSection(milestones)
                        }

                        if showsDashboardHighlights,
                           recentActivity.isEmpty == false {
                            activitySection(recentActivity)
                        }
                    }
                }
                .mhSurfaceInset()
            }
            .mhScreen(
                title: Text(FluelCopy.dashboard()),
                subtitle: Text(FluelCopy.dashboardScreenSubtitle())
            )
            .navigationBarTitleDisplayMode(.inline)
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
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(FluelCopy.quickActions())
                .font(.headline)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: theme.spacing.inline) {
                    quickActionButton(
                        title: FluelCopy.add(),
                        systemImage: "plus.circle",
                        style: .mhPrimary,
                        expandsHorizontally: false,
                        action: onAdd
                    )
                    quickActionButton(
                        title: FluelCopy.archived(),
                        systemImage: "archivebox",
                        style: .mhSecondary,
                        expandsHorizontally: false,
                        action: onShowArchive
                    )
                    quickActionButton(
                        title: FluelCopy.licenses(),
                        systemImage: "doc.text",
                        style: .mhSecondary,
                        expandsHorizontally: false,
                        action: onShowLicenses
                    )
                }

                VStack(alignment: .leading, spacing: theme.spacing.inline) {
                    quickActionButton(
                        title: FluelCopy.add(),
                        systemImage: "plus.circle",
                        style: .mhPrimary,
                        expandsHorizontally: true,
                        action: onAdd
                    )
                    quickActionButton(
                        title: FluelCopy.archived(),
                        systemImage: "archivebox",
                        style: .mhSecondary,
                        expandsHorizontally: true,
                        action: onShowArchive
                    )
                    quickActionButton(
                        title: FluelCopy.licenses(),
                        systemImage: "doc.text",
                        style: .mhSecondary,
                        expandsHorizontally: true,
                        action: onShowLicenses
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: .muted)
    }

    private func quickActionButton(
        title: String,
        systemImage: String,
        style: MHActionButtonStyle,
        expandsHorizontally: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            quickActionLabel(
                title: title,
                systemImage: systemImage,
                expandsHorizontally: expandsHorizontally
            )
        }
        .buttonStyle(style)
    }

    @ViewBuilder
    private func quickActionLabel(
        title: String,
        systemImage: String,
        expandsHorizontally: Bool
    ) -> some View {
        let label = Label(
            title,
            systemImage: systemImage
        )
        .lineLimit(1)
        .truncationMode(.tail)

        if expandsHorizontally {
            label
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            label
                .fixedSize(horizontal: true, vertical: false)
        }
    }

    private var emptyState: some View {
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

    private func overviewCard(
        _ snapshot: EntryCollectionSnapshot
    ) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(FluelCopy.overview())
                .font(.headline)

            LazyVGrid(
                columns: Metrics.metricColumns,
                alignment: .leading,
                spacing: theme.spacing.inline
            ) {
                metricTile(
                    title: FluelCopy.totalEntriesCount(snapshot.totalCount),
                    value: snapshot.totalCount.formatted()
                )
                metricTile(
                    title: FluelCopy.activeEntryCount(snapshot.activeCount),
                    value: snapshot.activeCount.formatted()
                )
                metricTile(
                    title: FluelCopy.archivedEntryCount(snapshot.archivedCount),
                    value: snapshot.archivedCount.formatted()
                )
                metricTile(
                    title: FluelCopy.withNotesCount(
                        snapshot.activeWithNotesCount + snapshot.archivedWithNotesCount
                    ),
                    value: (
                        snapshot.activeWithNotesCount + snapshot.archivedWithNotesCount
                    ).formatted()
                )
                metricTile(
                    title: FluelCopy.withPhotosCount(
                        snapshot.activeWithPhotosCount + snapshot.archivedWithPhotosCount
                    ),
                    value: (
                        snapshot.activeWithPhotosCount + snapshot.archivedWithPhotosCount
                    ).formatted()
                )

                if let mostRecentlyArchivedTitle = snapshot.mostRecentlyArchivedTitle {
                    metricTile(
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

    private func leadEntryCard(
        _ snapshot: EntryCollectionSnapshot
    ) -> AnyView? {
        guard let title = snapshot.leadActiveTitle,
              let startComponents = snapshot.leadActiveStartComponents,
              let elapsedSnapshot = snapshot.leadActiveElapsedSnapshot else {
            return nil
        }

        return AnyView(
            VStack(alignment: .leading, spacing: theme.spacing.inline) {
                Text(FluelCopy.leadEntry())
                    .font(.headline)

                Text(title)
                    .mhRowTitle()

                Text(
                    EntryFormatting.startLabelText(
                        for: startComponents
                    )
                )
                .mhRowSupporting()

                Text(
                    EntryFormatting.primaryElapsedText(
                        for: elapsedSnapshot
                    )
                )
                .font(.title2.weight(.semibold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .mhRow()
            .mhSurface()
        )
    }

    private func metricTile(
        title: String,
        value: String
    ) -> some View {
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

    private func milestoneSection(
        _ milestones: [EntryMilestoneSnapshot]
    ) -> some View {
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
                                FluelCopy.daysRemaining(
                                    milestone.daysRemaining
                                )
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

    private func activitySection(
        _ activity: [EntryActivitySnapshot]
    ) -> some View {
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

#Preview(traits: .modifier(FluelSampleData())) {
    NavigationStack {
        DashboardView(
            onAdd: {},
            onShowArchive: {},
            onShowLicenses: {}
        )
    }
    .fluelAppStyle()
}
