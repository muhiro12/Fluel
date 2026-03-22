import FluelLibrary
import SwiftData
import SwiftUI
import TipKit

struct DashboardView: View {
    @Query
    private var entries: [Entry]
    @AppStorage(
        DisplayPreferences.showsDashboardHighlights,
        store: DisplayPreferences.store
    )
    private var showsDashboardHighlights = true

    let onAdd: () -> Void
    let onCreateFromPreset: (String) -> Void
    let onShowArchive: () -> Void
    let onShowLicenses: () -> Void

    private let dashboardOverviewTip = FluelTips.DashboardOverviewTip()

    var body: some View {
        TimelineView(.periodic(from: .now, by: 3_600)) { timeline in // swiftlint:disable:this no_magic_numbers
            let content = FluelDashboardContent(
                entries: entries,
                referenceDate: timeline.date
            )

            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: FluelPresentationStyle.sectionSpacing
                ) {
                    FluelScreenIntroCard(
                        title: nil,
                        subtitle: FluelCopy.dashboardScreenSubtitle()
                    )

                    DashboardQuickActionsCard(
                        onAdd: onAdd,
                        onCreateFromPreset: onCreateFromPreset,
                        onShowArchive: onShowArchive,
                        onShowLicenses: onShowLicenses
                    )

                    if content.snapshot.totalCount == 0 {
                        DashboardEmptyState(onAdd: onAdd)
                    } else {
                        DashboardOverviewCard(snapshot: content.snapshot)
                            .popoverTip(
                                showsDashboardOverviewTip(
                                    for: content.snapshot
                                )
                                ? dashboardOverviewTip
                                : nil,
                                arrowEdge: .top
                            )

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
                .padding(FluelPresentationStyle.screenPadding)
            }
            .fluelAppBackground()
        }
        .navigationTitle(FluelCopy.dashboard())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .onDisappear {
            if entries.isEmpty == false {
                FluelTipState.markDashboardOverviewLearned()
            }
        }
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

private extension DashboardView {
    func showsDashboardOverviewTip(
        for snapshot: EntryCollectionSnapshot
    ) -> Bool {
        FluelTipBootstrap.isEnabled
            && FluelTipState.hasLearnedDashboardOverview == false
            && snapshot.totalCount > 0
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    @Previewable var presetStore = EntryPresetStore.preview()

    NavigationStack {
        DashboardView(
            onAdd: {},
            onCreateFromPreset: { _ in },
            onShowArchive: {},
            onShowLicenses: {}
        )
    }
    .environment(presetStore)
    .fluelAppStyle()
}
