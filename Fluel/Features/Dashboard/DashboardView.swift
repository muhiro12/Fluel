import FluelLibrary
import MHUI
import SwiftData
import SwiftUI

struct DashboardView: View {
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
            let content = FluelDashboardContent(
                entries: entries,
                referenceDate: timeline.date
            )

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.section) {
                    DashboardQuickActionsCard(
                        onAdd: onAdd,
                        onShowArchive: onShowArchive,
                        onShowLicenses: onShowLicenses
                    )

                    if content.snapshot.totalCount == 0 {
                        DashboardEmptyState(onAdd: onAdd)
                    } else {
                        DashboardOverviewCard(snapshot: content.snapshot)

                        if let leadEntry = content.leadEntry {
                            DashboardLeadEntryCard(leadEntry: leadEntry)
                        }

                        if showsDashboardHighlights,
                           content.milestones.isEmpty == false {
                            DashboardMilestoneSection(
                                milestones: content.milestones
                            )
                        }

                        if showsDashboardHighlights,
                           content.recentActivity.isEmpty == false {
                            DashboardActivitySection(
                                activity: content.recentActivity
                            )
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
