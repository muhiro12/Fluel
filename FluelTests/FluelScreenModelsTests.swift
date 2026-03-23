@testable import Fluel
import FluelLibrary
import Foundation
import Testing

@MainActor
struct FluelScreenModelsTests {
    @Test
    func home_screen_model_persists_sort_and_filter_preferences() {
        let defaults = makeDefaults()
        let model = HomeScreenModel(defaults: defaults)

        model.sortMode = .recentlyUpdated
        model.contentFilter = .withPhoto

        let reloaded = HomeScreenModel(defaults: defaults)

        #expect(reloaded.sortMode == .recentlyUpdated)
        #expect(reloaded.contentFilter == .withPhoto)
    }

    @Test
    func timeline_screen_model_persists_filter_preferences() {
        let defaults = makeDefaults()
        let model = TimelineScreenModel(defaults: defaults)

        model.activityFilter = .archived
        model.scopeFilter = .allTime

        let reloaded = TimelineScreenModel(defaults: defaults)

        #expect(reloaded.activityFilter == .archived)
        #expect(reloaded.scopeFilter == .allTime)
    }

    @Test
    func display_preferences_store_resets_all_toggles() {
        let defaults = makeDefaults()
        let store = FluelDisplayPreferencesStore(defaults: defaults)

        store.showsListSummaryCards = false
        store.showsNotePreviews = false
        store.showsMetadataBadges = false
        store.showsDashboardHighlights = false

        store.reset()

        #expect(store.showsListSummaryCards)
        #expect(store.showsNotePreviews)
        #expect(store.showsMetadataBadges)
        #expect(store.showsDashboardHighlights)

        let reloaded = FluelDisplayPreferencesStore(defaults: defaults)
        #expect(reloaded.showsListSummaryCards)
        #expect(reloaded.showsNotePreviews)
        #expect(reloaded.showsMetadataBadges)
        #expect(reloaded.showsDashboardHighlights)
    }

    @Test
    func settings_screen_model_tracks_display_reset_confirmation() {
        let model = SettingsScreenModel()

        model.presentDisplayResetConfirmation()
        #expect(model.isConfirmingDisplayReset)

        model.dismissDisplayResetConfirmation()
        #expect(model.isConfirmingDisplayReset == false)
    }

    @Test
    func entry_form_presentation_model_dismisses_on_degraded_success_and_posts_notice() {
        let noticeCenter = FluelNoticeCenter()
        let model = EntryFormPresentationModel()

        let effect = model.handle(
            .degradedSuccess(message: "Widget timelines could not be refreshed."),
            noticeCenter: noticeCenter
        )

        #expect(effect == .dismiss)
        #expect(model.errorMessage == nil)
        #expect(
            noticeCenter.activeNotice?.message == "Widget timelines could not be refreshed."
        )
    }

    @Test
    func preset_settings_screen_model_tracks_sheet_and_delete_routes() {
        let preset = EntryPreset(
            id: "custom",
            source: .custom,
            definition: .init(
                title: "Wallet",
                symbolName: "wallet.pass",
                startPrecision: .month,
                relativeValue: 6
            ),
            isPinned: false,
            lastUsedAt: nil,
            createdAt: nil,
            updatedAt: nil
        )
        let model = PresetSettingsScreenModel()

        model.presentCreate()
        #expect(model.sheetRoute == .create)

        model.presentEdit(preset)
        #expect(model.sheetRoute == .edit(preset))

        model.presentDelete(preset)
        #expect(model.deletingPreset == preset)

        model.dismissDeleteConfirmation()
        #expect(model.deletingPreset == nil)
    }

    @Test
    func entry_detail_presentation_model_tracks_routes_and_failure_message() {
        let noticeCenter = FluelNoticeCenter()
        let model = EntryDetailPresentationModel()

        model.presentEdit()
        #expect(model.sheetRoute == .edit)

        model.dismissSheet()
        #expect(model.sheetRoute == nil)

        model.presentDeleteConfirmation()
        #expect(model.isConfirmingDelete)

        let effect = model.handle(
            .failure(
                .init(
                    phase: .primaryMutation,
                    message: "Delete failed."
                )
            ),
            noticeCenter: noticeCenter
        )

        #expect(effect == .idle)
        #expect(model.errorMessage == "Delete failed.")
        #expect(noticeCenter.activeNotice == nil)
    }
}

private func makeDefaults() -> UserDefaults {
    UserDefaults(
        suiteName: "FluelScreenModelsTests.\(UUID().uuidString)"
    ) ?? .standard
}
