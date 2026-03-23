import SwiftUI

struct DashboardTabRootView: View {
    @Environment(EntryPresetStore.self)
    private var presetStore

    let router: MainTabRouter

    var body: some View {
        NavigationStack(path: dashboardPathBinding) {
            DashboardView(
                onAdd: presentCreateEntry,
                onCreateFromPreset: presentCreateEntry(presetID:),
                onShowArchive: showArchive,
                onShowLicenses: showLicenses
            )
            .navigationDestination(for: MainDestination.self) { destination in
                switch destination {
                case .archive:
                    ArchiveListView()
                }
            }
        }
        .sheet(item: dashboardSheetBinding) { sheet in
            MainSheetView(sheet: sheet)
        }
    }

    private var dashboardPathBinding: Binding<[MainDestination]> {
        .init(
            get: {
                router.dashboardPath
            },
            set: { newValue in
                router.dashboardPath = newValue
            }
        )
    }

    private var dashboardSheetBinding: Binding<MainSheetRoute?> {
        .init(
            get: {
                router.dashboardSheet
            },
            set: { newValue in
                router.dashboardSheet = newValue
            }
        )
    }

    private func presentCreateEntry() {
        presentCreateEntry(presetID: presetStore.defaultCreatePresetID)
    }

    private func presentCreateEntry(
        presetID: String?
    ) {
        FluelTipState.markEntryCreationLearned()
        router.presentDashboardCreate(presetID: presetID)
    }

    private func showArchive() {
        router.showDashboardArchive()
    }

    private func showLicenses() {
        router.presentDashboardLicenses()
    }
}
