import Observation

@MainActor
@Observable
final class PresetSettingsScreenModel {
    enum SheetRoute: Identifiable, Equatable {
        case create
        case edit(EntryPreset)

        var id: String {
            switch self {
            case .create:
                return "create"
            case let .edit(preset):
                return "edit-\(preset.id)"
            }
        }
    }

    var sheetRoute: SheetRoute?
    var deletingPreset: EntryPreset?

    func presentCreate() {
        sheetRoute = .create
    }

    func presentEdit(
        _ preset: EntryPreset
    ) {
        sheetRoute = .edit(preset)
    }

    func dismissSheet() {
        sheetRoute = nil
    }

    func presentDelete(
        _ preset: EntryPreset
    ) {
        deletingPreset = preset
    }

    func dismissDeleteConfirmation() {
        deletingPreset = nil
    }

    func showsDefaultPresetTip() -> Bool {
        FluelTipBootstrap.isEnabled
            && FluelTipState.hasLearnedDefaultPreset == false
    }
}
