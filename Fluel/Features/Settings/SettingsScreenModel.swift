import Observation

@MainActor
@Observable
final class SettingsScreenModel {
    var isConfirmingDisplayReset = false

    func showsPresetManagementTip() -> Bool {
        FluelTipBootstrap.isEnabled
            && FluelTipState.hasLearnedPresetManagement == false
    }

    func presentDisplayResetConfirmation() {
        isConfirmingDisplayReset = true
    }

    func dismissDisplayResetConfirmation() {
        isConfirmingDisplayReset = false
    }
}
