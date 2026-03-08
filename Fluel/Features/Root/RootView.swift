import FluelLibrary
import MHPlatform
import SwiftUI

struct RootView: View {
    private enum Tab: Hashable {
        case home
        case dashboard
        case settings
    }

    private enum Destination: Hashable {
        case archive
    }

    @Environment(MHAppRuntime.self)
    private var appRuntime

    @State private var selectedTab: Tab = .home
    @State private var isPresentingCreate = false
    @State private var isPresentingLicenses = false
    @State private var path = [Destination]()

    var body: some View {
        NavigationStack(path: $path) {
            TabView(selection: $selectedTab) {
                HomeView(
                    onAdd: {
                        isPresentingCreate = true
                    },
                    onShowArchive: {
                        path.append(.archive)
                    },
                    onShowLicenses: {
                        isPresentingLicenses = true
                    }
                )
                .tabItem {
                    Label(
                        FluelCopy.home(),
                        systemImage: "house"
                    )
                }
                .tag(Tab.home)

                DashboardView(
                    onAdd: {
                        isPresentingCreate = true
                    },
                    onShowArchive: {
                        path.append(.archive)
                    },
                    onShowLicenses: {
                        isPresentingLicenses = true
                    }
                )
                .tabItem {
                    Label(
                        FluelCopy.dashboard(),
                        systemImage: "square.grid.2x2"
                    )
                }
                .tag(Tab.dashboard)

                SettingsView(
                    onShowArchive: {
                        path.append(.archive)
                    },
                    onShowLicenses: {
                        isPresentingLicenses = true
                    }
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
        .sheet(isPresented: $isPresentingCreate) {
            NavigationStack {
                EntryFormView(mode: .create)
            }
        }
        .sheet(isPresented: $isPresentingLicenses) {
            NavigationStack {
                appRuntime.licensesView()
                    .navigationTitle(FluelCopy.licenses())
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    RootView()
        .environment(
            MHAppRuntime(
                configuration: FluelAppConfiguration.runtimeConfiguration
            )
        )
        .fluelAppStyle()
}
