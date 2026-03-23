import Observation

@MainActor
@Observable
final class SettingsScreenModel {
    func showsPresetManagementTip() -> Bool {
        FluelTipBootstrap.isEnabled
            && FluelTipState.hasLearnedPresetManagement == false
    }
}
