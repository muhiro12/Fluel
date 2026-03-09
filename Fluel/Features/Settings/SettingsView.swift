import FluelLibrary
import MHUI
import SwiftData
import SwiftUI
import TipKit

struct SettingsView: View {
    @Environment(\.mhTheme)
    private var theme
    @EnvironmentObject private var presetStore: EntryPresetStore

    @Query
    private var entries: [Entry]
    @AppStorage(
        DisplayPreferences.showsListSummaryCards,
        store: DisplayPreferences.store
    )
    private var showsListSummaryCards = true
    @AppStorage(
        DisplayPreferences.showsNotePreviews,
        store: DisplayPreferences.store
    )
    private var showsNotePreviews = true
    @AppStorage(
        DisplayPreferences.showsMetadataBadges,
        store: DisplayPreferences.store
    )
    private var showsMetadataBadges = true
    @AppStorage(
        DisplayPreferences.showsDashboardHighlights,
        store: DisplayPreferences.store
    )
    private var showsDashboardHighlights = true

    private let presetManagementTip = FluelTips.PresetManagementTip()

    let onShowArchive: () -> Void
    let onShowLicenses: () -> Void

    var body: some View {
        let snapshot = EntryCollectionSnapshotQuery.snapshot(
            entries: entries
        )

        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.section) {
                displayCard
                presetCard
                dataCard(snapshot)
                supportCard
            }
            .mhSurfaceInset()
        }
        .mhScreen(
            title: Text(FluelCopy.settings()),
            subtitle: Text(FluelCopy.settingsScreenSubtitle())
        )
        .navigationBarTitleDisplayMode(.inline)
    }

    private var displayCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(FluelCopy.display())
                .font(.headline)

            Toggle(
                FluelCopy.showListSummaryCards(),
                isOn: $showsListSummaryCards
            )

            Toggle(
                FluelCopy.showNotePreviews(),
                isOn: $showsNotePreviews
            )

            Toggle(
                FluelCopy.showMetadataBadges(),
                isOn: $showsMetadataBadges
            )

            Toggle(
                FluelCopy.showDashboardHighlights(),
                isOn: $showsDashboardHighlights
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: .muted)
    }

    private func dataCard(
        _ snapshot: EntryCollectionSnapshot
    ) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(FluelCopy.dataStatus())
                .font(.headline)

            Text(FluelCopy.totalEntriesCount(snapshot.totalCount))
                .mhRowTitle()

            Text(FluelCopy.activeEntryCount(snapshot.activeCount))
                .mhRowSupporting()

            Text(FluelCopy.archivedEntryCount(snapshot.archivedCount))
                .mhRowSupporting()

            if let leadActiveTitle = snapshot.leadActiveTitle {
                Text(
                    "\(FluelCopy.leadEntry()): \(leadActiveTitle)"
                )
                .mhTextStyle(.metadata, colorRole: .secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: .muted)
    }

    private var presetCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(FluelCopy.presets())
                .font(.headline)

            NavigationLink {
                PresetSettingsView()
                    .onAppear {
                        FluelTipState.markPresetManagementLearned()
                    }
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(FluelCopy.openPresets())
                        .mhRowTitle()

                    Text(
                        FluelCopy.presetCount(
                            presetStore.allPresets.count
                        )
                    )
                    .mhRowSupporting()

                    Text(
                        FluelCopy.pinnedPresetCount(
                            presetStore.pinnedPresets.count
                        )
                    )
                    .mhTextStyle(.metadata, colorRole: .secondaryText)

                    Text(
                        FluelCopy.customPresetCount(
                            presetStore.customPresets.count
                        )
                    )
                    .mhTextStyle(.metadata, colorRole: .secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: .muted)
        .popoverTip(
            showsPresetManagementTip ? presetManagementTip : nil,
            arrowEdge: .top
        )
    }

    private var supportCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(FluelCopy.support())
                .font(.headline)

            MHActionGroup(layout: .vertical) {
                Button(action: onShowArchive) {
                    Label(
                        FluelCopy.openArchivedEntries(),
                        systemImage: "archivebox"
                    )
                }
                .buttonStyle(.mhSecondary)

                Button(action: onShowLicenses) {
                    Label(
                        FluelCopy.openLicenses(),
                        systemImage: "doc.text"
                    )
                }
                .buttonStyle(.mhSecondary)

                Button(action: FluelTipBootstrap.resetTips) {
                    Label(
                        FluelCopy.showTipsAgain(),
                        systemImage: "lightbulb"
                    )
                }
                .buttonStyle(.mhSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: .muted)
    }

    private var showsPresetManagementTip: Bool {
        FluelTipBootstrap.isEnabled
            && FluelTipState.hasLearnedPresetManagement == false
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    NavigationStack {
        SettingsView(
            onShowArchive: {},
            onShowLicenses: {}
        )
    }
    .environmentObject(EntryPresetStore.preview())
    .fluelAppStyle()
}
