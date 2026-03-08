import Foundation

enum DisplayPreferences {
    static let store = UserDefaults(
        suiteName: FluelAppConfiguration.preferencesSuiteName
    ) ?? .standard

    static let showsListSummaryCards = "display_shows_list_summary_cards"
    static let showsNotePreviews = "display_shows_note_previews"
    static let showsMetadataBadges = "display_shows_metadata_badges"
    static let showsDashboardHighlights = "display_shows_dashboard_highlights"
}
