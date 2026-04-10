import MHPlatform
import SwiftUI

struct FluelDiagnosticsView: View {
    @Environment(MHLoggingBootstrap.self)
    private var logging

    var body: some View {
        MHLogConsoleView(logging: logging)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let previewEnvironment = FluelLoggingSupport.makePreviewEnvironment(
        diagnosticsEnabled: true
    )

    NavigationStack {
        FluelDiagnosticsView()
    }
    .environment(previewEnvironment.logging)
    .environment(previewEnvironment.debugSettings)
    .fluelAppStyle()
}
