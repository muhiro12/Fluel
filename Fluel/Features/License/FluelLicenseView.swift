import FluelLibrary
import MHPlatform
import SwiftData
import SwiftUI

struct FluelLicenseView: View {
    @Environment(MHAppRuntime.self)
    private var appRuntime

    var body: some View {
        appRuntime.licensesView()
            .navigationTitle(FluelCopy.licenses())
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    let context = try! FluelSampleData.makeSharedContext()

    return NavigationStack {
        FluelLicenseView()
    }
    .modelContainer(context.modelContainer)
    .mhAppRuntimeBootstrap(
        .init(
            configuration: FluelAppConfiguration.runtimeConfiguration,
            lifecyclePlan: FluelAppConfiguration.runtimeLifecyclePlan
        )
    )
    .fluelAppStyle()
}
