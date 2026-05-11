import MHPlatform
import SwiftUI

extension View {
    @ViewBuilder
    func fluelPreviewEnvironment(
        presetStore: EntryPresetStore? = nil,
        noticeCenter: FluelNoticeCenter = .init(),
        displayPreferences: FluelDisplayPreferencesStore = .preview(),
        diagnosticsEnabled: Bool = false,
        logging: MHLoggingBootstrap? = nil,
        debugSettings: FluelDebugSettingsStore? = nil
    ) -> some View {
        let previewEnvironment = {
            if let logging,
               let debugSettings {
                return FluelLoggingSupport.PreviewEnvironment(
                    logging: logging,
                    debugSettings: debugSettings
                )
            }

            return FluelLoggingSupport.makePreviewEnvironment(
                diagnosticsEnabled: diagnosticsEnabled
            )
        }()

        let base = environment(noticeCenter)
            .environment(displayPreferences)
            .environment(previewEnvironment.logging)
            .environment(previewEnvironment.debugSettings)

        if let presetStore {
            base.environment(presetStore)
        } else {
            base
        }
    }
}
