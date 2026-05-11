import SwiftUI

struct SettingsTabRootView: View {
    let router: MainTabRouter

    var body: some View {
        NavigationStack(path: settingsPathBinding) {
            SettingsView(
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
        .sheet(item: settingsSheetBinding) { sheet in
            MainSheetView(sheet: sheet)
        }
    }

    private var settingsPathBinding: Binding<[MainDestination]> {
        .init(
            get: {
                router.settingsPath
            },
            set: { newValue in
                router.settingsPath = newValue
            }
        )
    }

    private var settingsSheetBinding: Binding<MainSheetRoute?> {
        .init(
            get: {
                router.settingsSheet
            },
            set: { newValue in
                router.settingsSheet = newValue
            }
        )
    }

    private func showArchive() {
        router.showSettingsArchive()
    }

    private func showLicenses() {
        router.presentSettingsLicenses()
    }
}
