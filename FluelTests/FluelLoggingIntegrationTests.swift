@testable import Fluel
import FluelLibrary
import Foundation
import Testing

@MainActor
struct FluelLoggingIntegrationTests {
    @Test
    func display_preferences_store_logs_toggle_changes_and_reset() async {
        let defaults = makeDefaults()
        let logProbe = FluelLogProbe()
        let store = FluelDisplayPreferencesStore(
            defaults: defaults,
            logger: logProbe.logger(category: "DisplayPreferences")
        )

        store.showsNotePreviews = false
        store.reset()

        let events = await recordedEvents(
            from: logProbe
        )

        #expect(events.contains { event in
            event.message == "Display preference updated"
                && event.metadata["setting"] == "showsNotePreviews"
                && event.metadata["isEnabled"] == "false"
        })
        #expect(events.contains { event in
            event.message == "Display preferences reset"
        })
    }

    @Test
    func debug_settings_store_persists_mode_and_updates_capture_level() {
        let suiteName = "FluelDebugSettingsStoreTests.\(UUID().uuidString)"
        let environment = FluelLoggingSupport.makePreviewEnvironment(
            suiteName: suiteName
        )
        let store = environment.debugSettings

        #expect(store.isDiagnosticsEnabled == false)
        #expect(store.captureLevelName == "warning")

        store.isDiagnosticsEnabled = true

        let reloadedEnvironment = FluelLoggingSupport.makePreviewEnvironment(
            suiteName: suiteName
        )
        let reloadedStore = reloadedEnvironment.debugSettings

        #expect(reloadedStore.isDiagnosticsEnabled)
        #expect(reloadedStore.captureLevelName == "debug")
    }

    @Test
    func preset_store_logs_custom_preset_changes() async throws {
        let defaults = makeDefaults()
        let logProbe = FluelLogProbe()
        let store = EntryPresetStore(
            defaults: defaults,
            logger: logProbe.logger(category: "PresetStore")
        )

        store.saveCustomPreset(
            definition: .init(
                title: "Wallet",
                symbolName: "wallet.pass",
                startPrecision: .month,
                relativeValue: 6,
                note: "kept"
            )
        )

        let presetID = try #require(store.customPresets.first?.id)
        store.setPinned(true, for: presetID)
        store.setDefaultPreset(id: presetID)
        store.setUsesDefaultPreset(true)
        store.markUsed(presetID)
        store.deleteCustomPreset(id: presetID)

        let events = await recordedEvents(
            from: logProbe
        )

        #expect(events.contains { event in
            event.message == "Preset stored"
                && event.metadata["action"] == "create"
        })
        #expect(events.contains { event in
            event.message == "Preset pin state updated"
                && event.metadata["presetID"] == presetID
        })
        #expect(events.contains { event in
            event.message == "Default preset updated"
                && event.metadata["presetID"] == presetID
        })
        #expect(events.contains { event in
            event.message == "Default preset usage updated"
                && event.metadata["isEnabled"] == "true"
        })
        #expect(events.contains { event in
            event.message == "Preset marked used"
                && event.metadata["presetID"] == presetID
        })
        #expect(events.contains { event in
            event.message == "Preset deleted"
                && event.metadata["presetID"] == presetID
        })
    }

    @Test
    func preset_store_logs_decode_failures_and_repairs_default_selection() async {
        let defaults = makeDefaults()
        let logProbe = FluelLogProbe()

        defaults.set(
            Data("not-json".utf8),
            forKey: EntryPresetPreferences.customPresetRecords
        )
        defaults.set(
            "missing-preset",
            forKey: EntryPresetPreferences.defaultPresetID
        )
        defaults.set(
            true,
            forKey: EntryPresetPreferences.usesDefaultPreset
        )

        let store = EntryPresetStore(
            defaults: defaults,
            logger: logProbe.logger(category: "PresetStore")
        )

        #expect(store.customPresets.isEmpty)
        #expect(store.defaultPresetID == nil)
        #expect(store.usesDefaultPreset == false)

        let events = await recordedEvents(
            from: logProbe
        )

        #expect(events.contains { event in
            event.message == "Preset record decode failed"
        })
        #expect(events.contains { event in
            event.message == "Default preset selection repaired"
                && event.metadata["reason"] == "missingPresetRecord"
        })
    }
}

private func makeDefaults() -> UserDefaults {
    UserDefaults(
        suiteName: "FluelLoggingIntegrationTests.\(UUID().uuidString)"
    ) ?? .standard
}

private extension FluelLoggingIntegrationTests {
    func recordedEvents(
        from probe: FluelLogProbe
    ) async -> [FluelRecordedLogEvent] {
        await Task.yield()
        await Task.yield()
        return await probe.events()
    }
}
