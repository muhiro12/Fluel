import FluelLibrary
import SwiftUI

#Preview(traits: .modifier(FluelSampleData())) {
    @Previewable var presetStore = EntryPresetStore.preview()

    NavigationStack {
        SettingsView(
            onShowArchive: {
                // Preview only.
            },
            onShowLicenses: {
                // Preview only.
            }
        )
    }
    .fluelPreviewEnvironment(presetStore: presetStore)
    .fluelAppStyle()
}
