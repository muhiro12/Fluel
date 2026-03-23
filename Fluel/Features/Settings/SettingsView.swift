// swiftlint:disable attributes closure_body_length no_empty_block
// swiftlint:disable no_magic_numbers type_contents_order
import FluelLibrary
import MHUI
import SwiftData
import SwiftUI
import TipKit

struct SettingsView: View {
    @Environment(\.mhTheme)
    private var theme
    @Environment(EntryPresetStore.self)
    private var presetStore
    @Environment(FluelDisplayPreferencesStore.self)
    private var displayPreferences
    @Environment(FluelNoticeCenter.self)
    private var noticeCenter

    @Query
    private var entries: [Entry]
    @State private var model = SettingsScreenModel()

    private let presetManagementTip = FluelTips.PresetManagementTip()

    let onShowArchive: () -> Void
    let onShowLicenses: () -> Void

    private var showsListSummaryCardsBinding: Binding<Bool> {
        .init(
            get: {
                displayPreferences.showsListSummaryCards
            },
            set: { newValue in
                displayPreferences.showsListSummaryCards = newValue
            }
        )
    }

    private var showsNotePreviewsBinding: Binding<Bool> {
        .init(
            get: {
                displayPreferences.showsNotePreviews
            },
            set: { newValue in
                displayPreferences.showsNotePreviews = newValue
            }
        )
    }

    private var showsMetadataBadgesBinding: Binding<Bool> {
        .init(
            get: {
                displayPreferences.showsMetadataBadges
            },
            set: { newValue in
                displayPreferences.showsMetadataBadges = newValue
            }
        )
    }

    private var showsDashboardHighlightsBinding: Binding<Bool> {
        .init(
            get: {
                displayPreferences.showsDashboardHighlights
            },
            set: { newValue in
                displayPreferences.showsDashboardHighlights = newValue
            }
        )
    }

    var body: some View {
        let snapshot = EntryCollectionSnapshotQuery.snapshot(
            entries: entries
        )

        ScrollView {
            VStack(alignment: .leading, spacing: theme.fluelSectionSpacing) {
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
        .toolbarRole(.editor)
        .confirmationDialog(
            FluelCopy.resetDisplayPreferencesConfirmationTitle(),
            isPresented: Binding(
                get: {
                    model.isConfirmingDisplayReset
                },
                set: { isPresented in
                    if isPresented == false {
                        model.dismissDisplayResetConfirmation()
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            Button(
                FluelCopy.resetDisplayPreferences(),
                role: .destructive
            ) {
                displayPreferences.reset()
                model.dismissDisplayResetConfirmation()
                noticeCenter.presentInfo(
                    message: FluelCopy.displayPreferencesResetNotice()
                )
            }

            Button(
                FluelCopy.cancel(),
                role: .cancel
            ) {
                model.dismissDisplayResetConfirmation()
            }
        } message: {
            Text(FluelCopy.resetDisplayPreferencesConfirmationMessage())
        }
    }

    private var displayCard: some View {
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            Text(FluelCopy.display())
                .mhTextStyle(.sectionTitle)

            Toggle(
                FluelCopy.showListSummaryCards(),
                isOn: showsListSummaryCardsBinding
            )

            Toggle(
                FluelCopy.showNotePreviews(),
                isOn: showsNotePreviewsBinding
            )

            Toggle(
                FluelCopy.showMetadataBadges(),
                isOn: showsMetadataBadgesBinding
            )

            Toggle(
                FluelCopy.showDashboardHighlights(),
                isOn: showsDashboardHighlightsBinding
            )

            Button {
                model.presentDisplayResetConfirmation()
            } label: {
                Label(
                    FluelCopy.resetDisplayPreferences(),
                    systemImage: "arrow.counterclockwise"
                )
            }
            .buttonStyle(.mhSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: .muted)
    }

    private func dataCard(
        _ snapshot: EntryCollectionSnapshot
    ) -> some View {
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            Text(FluelCopy.dataStatus())
                .mhTextStyle(.sectionTitle)

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
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            Text(FluelCopy.presets())
                .mhTextStyle(.sectionTitle)

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
            model.showsPresetManagementTip() ? presetManagementTip : nil,
            arrowEdge: .top
        )
    }

    private var supportCard: some View {
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            Text(FluelCopy.support())
                .mhTextStyle(.sectionTitle)

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
}

#Preview(traits: .modifier(FluelSampleData())) {
    @Previewable var presetStore = EntryPresetStore.preview()

    NavigationStack {
        SettingsView(
            onShowArchive: {},
            onShowLicenses: {}
        )
    }
    .fluelPreviewEnvironment(presetStore: presetStore)
    .fluelAppStyle()
}
