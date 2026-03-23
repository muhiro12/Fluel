import SwiftUI

struct MainSheetView: View {
    @Environment(EntryPresetStore.self)
    private var presetStore

    let sheet: MainSheetRoute

    var body: some View {
        NavigationStack {
            switch sheet {
            case let .create(presetID):
                EntryFormView(
                    mode: .create,
                    prefilledInput: presetID.flatMap { presetIdentifier in
                        presetStore.resolvedInput(for: presetIdentifier)
                    },
                    initialPresetID: presetID
                )
            case .licenses:
                FluelLicenseView()
            }
        }
    }
}
