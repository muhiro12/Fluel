import FluelLibrary
import MHUI
import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.mhTheme)
    private var theme

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

    let onShowArchive: () -> Void
    let onShowLicenses: () -> Void

    var body: some View {
        let snapshot = EntryCollectionSnapshotQuery.snapshot(
            entries: entries
        )

        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.section) {
                displayCard
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

    private var supportCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(FluelCopy.support())
                .font(.headline)

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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: .muted)
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    NavigationStack {
        SettingsView(
            onShowArchive: {},
            onShowLicenses: {}
        )
    }
    .fluelAppStyle()
}
