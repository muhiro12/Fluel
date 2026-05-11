import SwiftUI

struct HomeTabRootView: View {
    @Environment(EntryPresetStore.self)
    private var presetStore

    let router: MainTabRouter

    var body: some View {
        NavigationStack(path: homePathBinding) {
            HomeView(
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
        .sheet(item: homeSheetBinding) { sheet in
            MainSheetView(sheet: sheet)
        }
    }

    private var homePathBinding: Binding<[MainDestination]> {
        .init(
            get: {
                router.homePath
            },
            set: { newValue in
                router.homePath = newValue
            }
        )
    }

    private var homeSheetBinding: Binding<MainSheetRoute?> {
        .init(
            get: {
                router.homeSheet
            },
            set: { newValue in
                router.homeSheet = newValue
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
        router.presentHomeCreate(presetID: presetID)
    }

    private func showArchive() {
        router.showHomeArchive()
    }

    private func showLicenses() {
        router.presentHomeLicenses()
    }
}
