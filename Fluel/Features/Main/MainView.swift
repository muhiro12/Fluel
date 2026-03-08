import FluelLibrary
import MHPlatform
import SwiftUI

struct MainView: View {
    private enum Tab: Hashable {
        case home
        case dashboard
        case settings
    }

    private enum Destination: Hashable {
        case archive
    }

    private enum Sheet: String, Identifiable {
        case create
        case licenses

        var id: String {
            rawValue
        }
    }

    @Environment(MHAppRuntime.self)
    private var appRuntime

    @State private var selectedTab: Tab = .home
    @State private var path = [Destination]()
    @State private var activeSheet: Sheet?

    var body: some View {
        NavigationStack(path: $path) {
            TabView(selection: $selectedTab) {
                HomeView(
                    onAdd: presentCreateEntry,
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

                DashboardView(
                    onAdd: presentCreateEntry,
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
        .sheet(item: $activeSheet) { sheet in
            NavigationStack {
                switch sheet {
                case .create:
                    EntryFormView(mode: .create)
                case .licenses:
                    FluelLicenseView()
                }
            }
        }
        .mhAppRuntimeLifecycle(
            runtime: appRuntime,
            plan: FluelRuntimeLifecycleSupport.makePlan()
        )
    }
}

private extension MainView {
    func presentCreateEntry() {
        activeSheet = .create
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
            .fluelPlatformEnvironment(
                .preview(modelContainer: context.modelContainer)
            )
            .fluelAppStyle()
    } else {
        Text("Failed to load preview")
    }
}
