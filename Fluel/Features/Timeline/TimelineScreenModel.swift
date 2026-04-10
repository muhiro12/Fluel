import FluelLibrary
import Foundation
import MHPlatform
import Observation

@MainActor
@Observable
final class TimelineScreenModel {
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var logger: MHLogger?

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
            logPreferenceChange(
                name: "activityFilter",
                oldValue: oldValue.rawValue,
                newValue: activityFilter.rawValue
            )
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
            logPreferenceChange(
                name: "scopeFilter",
                oldValue: oldValue.rawValue,
                newValue: scopeFilter.rawValue
            )
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

    func attachLogger(
        _ logger: MHLogger
    ) {
        self.logger = logger
    }

    private func logPreferenceChange(
        name: String,
        oldValue: String,
        newValue: String
    ) {
        guard oldValue != newValue else {
            return
        }

        logger?.notice(
            "Timeline preference updated",
            metadata: [
                "setting": name,
                "value": newValue
            ]
        )
    }
}
