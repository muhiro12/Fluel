import MHAppRuntime
import SwiftUI

struct FluelLicenseView: View {
    @Environment(MHAppRuntime.self)
    private var runtime

    var body: some View {
        runtime.licensesView()
            .navigationTitle(FluelCopy.licenses())
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FluelLicenseView()
    }
    .mhAppRuntimeEnvironment(
        .init(configuration: FluelAppConfiguration.captureRuntimeConfiguration)
    )
    .fluelAppStyle()
}
