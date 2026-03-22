import FluelLibrary
import SwiftData
import SwiftUI
import TipKit

struct SettingsView: View {
    @Environment(EntryPresetStore.self)
    private var presetStore

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
            VStack(
                alignment: .leading,
                spacing: FluelPresentationStyle.sectionSpacing
            ) {
                FluelScreenIntroCard(
                    title: FluelCopy.settings(),
                    subtitle: FluelCopy.settingsScreenSubtitle()
                )

                displayCard
                presetCard
                dataCard(snapshot)
                supportCard
            }
            .padding(FluelPresentationStyle.screenPadding)
        }
        .fluelAppBackground()
        .navigationTitle(FluelCopy.settings())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
    }

    private var displayCard: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(FluelCopy.display())
                .fluelSectionTitleStyle()

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
        .fluelCard(tone: .muted)
    }

    private func dataCard(
        _ snapshot: EntryCollectionSnapshot
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(FluelCopy.dataStatus())
                .fluelSectionTitleStyle()

            Text(FluelCopy.totalEntriesCount(snapshot.totalCount))
                .fluelRowTitleStyle()

            Text(FluelCopy.activeEntryCount(snapshot.activeCount))
                .fluelSupportingStyle()

            Text(FluelCopy.archivedEntryCount(snapshot.archivedCount))
                .fluelSupportingStyle()

            if let leadActiveTitle = snapshot.leadActiveTitle {
                Text(
                    "\(FluelCopy.leadEntry()): \(leadActiveTitle)"
                )
                .fluelMetadataStyle()
            }
        }
        .fluelCard(tone: .muted)
    }

    private var presetCard: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(FluelCopy.presets())
                .fluelSectionTitleStyle()

            NavigationLink {
                PresetSettingsView()
                    .onAppear {
                        FluelTipState.markPresetManagementLearned()
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(FluelCopy.openPresets())
                            .fluelRowTitleStyle()

                        Text(
                            FluelCopy.presetCount(
                                presetStore.allPresets.count
                            )
                        )
                        .fluelSupportingStyle()

                        Text(
                            FluelCopy.pinnedPresetCount(
                                presetStore.pinnedPresets.count
                            )
                        )
                        .fluelMetadataStyle()

                        Text(
                            FluelCopy.customPresetCount(
                                presetStore.customPresets.count
                            )
                        )
                        .fluelMetadataStyle()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            .buttonStyle(.plain)
        }
        .fluelCard(tone: .muted)
        .popoverTip(
            showsPresetManagementTip ? presetManagementTip : nil,
            arrowEdge: .top
        )
    }

    private var supportCard: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(FluelCopy.support())
                .fluelSectionTitleStyle()

            VStack(alignment: .leading, spacing: FluelPresentationStyle.inlineSpacing) {
                Button(action: onShowArchive) {
                    Label(
                        FluelCopy.openArchivedEntries(),
                        systemImage: "archivebox"
                    )
                }
                .buttonStyle(.bordered)

                Button(action: onShowLicenses) {
                    Label(
                        FluelCopy.openLicenses(),
                        systemImage: "doc.text"
                    )
                }
                .buttonStyle(.bordered)

                Button(action: FluelTipBootstrap.resetTips) {
                    Label(
                        FluelCopy.showTipsAgain(),
                        systemImage: "lightbulb"
                    )
                }
                .buttonStyle(.bordered)
            }
        }
        .fluelCard(tone: .muted)
    }

    private var showsPresetManagementTip: Bool {
        FluelTipBootstrap.isEnabled
            && FluelTipState.hasLearnedPresetManagement == false
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    @Previewable var presetStore = EntryPresetStore.preview()

    NavigationStack {
        SettingsView(
            onShowArchive: {},
            onShowLicenses: {}
        )
    }
    .environment(presetStore)
    .fluelAppStyle()
}
