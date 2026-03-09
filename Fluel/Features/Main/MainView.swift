import FluelLibrary
import SwiftData
import SwiftUI

struct MainView: View {
    private enum Tab: Hashable {
        case home
        case timeline
        case dashboard
        case settings
    }

    private enum Destination: Hashable {
        case archive
    }

    private enum Sheet: Identifiable {
        case create(presetID: String?)
        case licenses

        var id: String {
            switch self {
            case let .create(presetID):
                if let presetID {
                    return "create-\(presetID)"
                }

                return "create"
            case .licenses:
                return "licenses"
            }
        }
    }

    @StateObject private var presetStore = EntryPresetStore()
    @State private var selectedTab: Tab = .home
    @State private var path = [Destination]()
    @State private var activeSheet: Sheet?

    var body: some View {
        NavigationStack(path: $path) {
            TabView(selection: $selectedTab) {
                HomeView(
                    onAdd: presentCreateEntry,
                    onCreateFromPreset: presentCreateEntry(presetID:),
                    onShowArchive: showArchive,
                    onShowLicenses: showLicenses
                )
                .tabItem {
                    Label(
                        FluelCopy.home(),
                        systemImage: "house"
                    )
                }
                .tag(Tab.home)

                ActivityTimelineView(
                    onAdd: presentCreateEntry
                )
                .tabItem {
                    Label(
                        FluelCopy.timeline(),
                        systemImage: "clock"
                    )
                }
                .tag(Tab.timeline)

                DashboardView(
                    onAdd: presentCreateEntry,
                    onCreateFromPreset: presentCreateEntry(presetID:),
                    onShowArchive: showArchive,
                    onShowLicenses: showLicenses
                )
                .tabItem {
                    Label(
                        FluelCopy.dashboard(),
                        systemImage: "square.grid.2x2"
                    )
                }
                .tag(Tab.dashboard)

                SettingsView(
                    onShowArchive: showArchive,
                    onShowLicenses: showLicenses
                )
                .tabItem {
                    Label(
                        FluelCopy.settings(),
                        systemImage: "gearshape"
                    )
                }
                .tag(Tab.settings)
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .archive:
                    ArchiveListView()
                }
            }
        }
        .environmentObject(presetStore)
        .sheet(item: $activeSheet) { sheet in
            NavigationStack {
                switch sheet {
                case let .create(presetID):
                    EntryFormView(
                        mode: .create,
                        prefilledInput: presetID.flatMap { presetStore.resolvedInput(for: $0) },
                        initialPresetID: presetID
                    )
                case .licenses:
                    FluelLicenseView()
                }
            }
        }
    }
}

private extension MainView {
    func presentCreateEntry() {
        presentCreateEntry(
            presetID: presetStore.defaultCreatePresetID
        )
    }

    func presentCreateEntry(
        presetID: String?
    ) {
        FluelTipState.markEntryCreationLearned()
        activeSheet = .create(presetID: presetID)
    }

    func showArchive() {
        path.append(.archive)
    }

    func showLicenses() {
        activeSheet = .licenses
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    if let context = try? FluelSampleData.makeSharedContext() {
        MainView()
            .modelContainer(context.modelContainer)
            .fluelAppStyle()
    } else {
        Text(FluelCopy.failedToLoadPreview())
    }
}
