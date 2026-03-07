import FluelLibrary
import MHPlatform
import SwiftUI

struct RootView: View {
    @Environment(MHAppRuntime.self)
    private var appRuntime

    @State private var isPresentingCreate = false
    @State private var isPresentingLicenses = false
    @State private var isShowingArchive = false

    var body: some View {
        NavigationStack {
            HomeView(
                onAdd: {
                    isPresentingCreate = true
                },
                onShowArchive: {
                    isShowingArchive = true
                },
                onShowLicenses: {
                    isPresentingLicenses = true
                }
            )
            .navigationDestination(isPresented: $isShowingArchive) {
                ArchiveListView()
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
