import FluelLibrary
import MHPlatform
import SwiftUI

struct AppRootView: View {
    @Environment(\.scenePhase)
    private var scenePhase

    @Environment(MHAppRuntime.self)
    private var appRuntime

    var body: some View {
        RootView()
            .task {
                appRuntime.startIfNeeded()
            }
            .onChange(of: scenePhase) {
                guard scenePhase == .active else {
                    return
                }

                appRuntime.startIfNeeded()
            }
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    AppRootView()
        .environment(
            MHAppRuntime(
                configuration: FluelAppConfiguration.runtimeConfiguration
            )
        )
}
