import FluelLibrary
import Foundation
import Observation

@MainActor
@Observable
final class TimelineScreenModel {
    @ObservationIgnored private let defaults: UserDefaults

    var searchText = String()
    var activityFilter: EntryActivityFilterMode {
        didSet {
            EntryListPreferences.setTimelineActivityFilter(
                activityFilter,
                defaults: defaults
            )
            if activityFilter != .all {
                FluelTipState.markTimelineFiltersLearned()
            }
        }
    }

    var scopeFilter: EntryActivityScopeMode {
        didSet {
            EntryListPreferences.setTimelineScopeFilter(
                scopeFilter,
                defaults: defaults
            )
            if scopeFilter != .recentSixMonths {
                FluelTipState.markTimelineFiltersLearned()
            }
        }
    }

    var hasActiveSearch: Bool {
        searchText.isEmpty == false
    }

    var hasActiveFilter: Bool {
        activityFilter != .all || scopeFilter != .recentSixMonths
    }

    init(
        defaults: UserDefaults = EntryListPreferences.store
    ) {
        self.defaults = defaults
        activityFilter = EntryListPreferences.loadTimelineActivityFilter(
            defaults: defaults
        )
        scopeFilter = EntryListPreferences.loadTimelineScopeFilter(
            defaults: defaults
        )
    }

    func showsTimelineFiltersTip(
        hasEntries: Bool
    ) -> Bool {
        FluelTipBootstrap.isEnabled
            && FluelTipState.hasLearnedTimelineFilters == false
            && hasEntries
    }

    func clearSearch() {
        searchText = String()
    }

    func clearFilters() {
        activityFilter = .all
        scopeFilter = .recentSixMonths
    }
}
