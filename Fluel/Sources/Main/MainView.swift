import FluelLibrary
import SwiftData
import SwiftUI

struct MainView: View {
    @State private var router = MainTabRouter()

    var body: some View {
        TabView {
            Tab(
                FluelCopy.home(),
                systemImage: "house"
            ) {
                HomeTabRootView(router: router)
            }

            Tab(
                FluelCopy.timeline(),
                systemImage: "clock"
            ) {
                TimelineTabRootView(router: router)
            }

            Tab(
                FluelCopy.dashboard(),
                systemImage: "square.grid.2x2"
            ) {
                DashboardTabRootView(router: router)
            }

            Tab(
                FluelCopy.settings(),
                systemImage: "gearshape"
            ) {
                SettingsTabRootView(router: router)
            }
        }
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    @Previewable var presetStore = EntryPresetStore.preview()

    if let context = try? FluelSampleData.makeSharedContext() {
        MainView()
            .modelContainer(context.modelContainer)
            .fluelPreviewEnvironment(presetStore: presetStore)
            .fluelAppStyle()
    } else {
        Text(FluelCopy.failedToLoadPreview())
    }
}
