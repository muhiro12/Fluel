import Foundation

enum EntryPresetPreferences {
    static let store = FluelSharedPreferences.store

    static let customPresetRecords = "entry_preset_custom_records"
    static let presetStates = "entry_preset_states"
    static let defaultPresetID = "entry_preset_default_id"
    static let usesDefaultPreset = "entry_preset_uses_default"
}
