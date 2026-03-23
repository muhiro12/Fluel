import Foundation
import Observation

@MainActor
@Observable
final class FluelDisplayPreferencesStore {
    @ObservationIgnored private let defaults: UserDefaults

    var showsListSummaryCards: Bool {
        didSet {
            DisplayPreferences.setShowsListSummaryCards(
                showsListSummaryCards,
                defaults: defaults
            )
        }
    }

    var showsNotePreviews: Bool {
        didSet {
            DisplayPreferences.setShowsNotePreviews(
                showsNotePreviews,
                defaults: defaults
            )
        }
    }

    var showsMetadataBadges: Bool {
        didSet {
            DisplayPreferences.setShowsMetadataBadges(
                showsMetadataBadges,
                defaults: defaults
            )
        }
    }

    var showsDashboardHighlights: Bool {
        didSet {
            DisplayPreferences.setShowsDashboardHighlights(
                showsDashboardHighlights,
                defaults: defaults
            )
        }
    }

    var customizedSettingCount: Int {
        [
            showsListSummaryCards,
            showsNotePreviews,
            showsMetadataBadges,
            showsDashboardHighlights
        ]
        .reduce(into: 0) { count, isEnabled in
            if isEnabled == false {
                count += 1
            }
        }
    }

    var usesDefaultSettings: Bool {
        customizedSettingCount == 0
    }

    init(
        defaults: UserDefaults = DisplayPreferences.store
    ) {
        self.defaults = defaults
        showsListSummaryCards = DisplayPreferences.loadShowsListSummaryCards(
            defaults: defaults
        )
        showsNotePreviews = DisplayPreferences.loadShowsNotePreviews(
            defaults: defaults
        )
        showsMetadataBadges = DisplayPreferences.loadShowsMetadataBadges(
            defaults: defaults
        )
        showsDashboardHighlights = DisplayPreferences.loadShowsDashboardHighlights(
            defaults: defaults
        )
    }

    static func preview() -> FluelDisplayPreferencesStore {
        let defaults = UserDefaults(
            suiteName: "FluelDisplayPreferences.preview.\(UUID().uuidString)"
        ) ?? .standard

        return .init(defaults: defaults)
    }

    func reset() {
        showsListSummaryCards = true
        showsNotePreviews = true
        showsMetadataBadges = true
        showsDashboardHighlights = true
    }
}
