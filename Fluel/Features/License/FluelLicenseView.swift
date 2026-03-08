import FluelLibrary
import MHPlatform
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
    .fluelPlatformEnvironment(
        .preview(modelContainer: context.modelContainer)
    )
    .fluelAppStyle()
}
