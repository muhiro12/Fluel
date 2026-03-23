import Foundation

enum DisplayPreferences {
    static let store = FluelSharedPreferences.store

    static let showsListSummaryCards = "display_shows_list_summary_cards"
    static let showsNotePreviews = "display_shows_note_previews"
    static let showsMetadataBadges = "display_shows_metadata_badges"
    static let showsDashboardHighlights = "display_shows_dashboard_highlights"

    static func loadShowsListSummaryCards(
        defaults: UserDefaults = store
    ) -> Bool {
        defaults.object(forKey: showsListSummaryCards) as? Bool ?? true
    }

    static func setShowsListSummaryCards(
        _ value: Bool,
        defaults: UserDefaults = store
    ) {
        defaults.set(value, forKey: showsListSummaryCards)
    }

    static func loadShowsNotePreviews(
        defaults: UserDefaults = store
    ) -> Bool {
        defaults.object(forKey: showsNotePreviews) as? Bool ?? true
    }

    static func setShowsNotePreviews(
        _ value: Bool,
        defaults: UserDefaults = store
    ) {
        defaults.set(value, forKey: showsNotePreviews)
    }

    static func loadShowsMetadataBadges(
        defaults: UserDefaults = store
    ) -> Bool {
        defaults.object(forKey: showsMetadataBadges) as? Bool ?? true
    }

    static func setShowsMetadataBadges(
        _ value: Bool,
        defaults: UserDefaults = store
    ) {
        defaults.set(value, forKey: showsMetadataBadges)
    }

    static func loadShowsDashboardHighlights(
        defaults: UserDefaults = store
    ) -> Bool {
        defaults.object(forKey: showsDashboardHighlights) as? Bool ?? true
    }

    static func setShowsDashboardHighlights(
        _ value: Bool,
        defaults: UserDefaults = store
    ) {
        defaults.set(value, forKey: showsDashboardHighlights)
    }
}
