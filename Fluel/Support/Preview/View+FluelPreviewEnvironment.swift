import SwiftUI

extension View {
    @ViewBuilder
    func fluelPreviewEnvironment(
        presetStore: EntryPresetStore? = nil,
        noticeCenter: FluelNoticeCenter = .init(),
        displayPreferences: FluelDisplayPreferencesStore = .preview()
    ) -> some View {
        let base = environment(noticeCenter)
            .environment(displayPreferences)

        if let presetStore {
            base.environment(presetStore)
        } else {
            base
        }
    }
}
