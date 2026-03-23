import FluelLibrary
import Foundation

enum EntryListPreferences {
    static let store = FluelSharedPreferences.store

    static let homeSortMode = "home_list_sort_mode"
    static let homeContentFilter = "home_list_content_filter"
    static let archiveSortMode = "archive_list_sort_mode"
    static let archiveContentFilter = "archive_list_content_filter"
    static let timelineActivityFilter = "timeline_activity_filter"
    static let timelineScopeFilter = "timeline_scope_filter"

    static func loadHomeSortMode(
        defaults: UserDefaults = store
    ) -> ActiveEntrySortMode {
        ActiveEntrySortMode(
            rawValue: defaults.string(forKey: homeSortMode) ?? String()
        ) ?? .oldestFirst
    }

    static func setHomeSortMode(
        _ value: ActiveEntrySortMode,
        defaults: UserDefaults = store
    ) {
        defaults.set(value.rawValue, forKey: homeSortMode)
    }

    static func loadHomeContentFilter(
        defaults: UserDefaults = store
    ) -> EntryContentFilterMode {
        EntryContentFilterMode(
            rawValue: defaults.string(forKey: homeContentFilter) ?? String()
        ) ?? .all
    }

    static func setHomeContentFilter(
        _ value: EntryContentFilterMode,
        defaults: UserDefaults = store
    ) {
        defaults.set(value.rawValue, forKey: homeContentFilter)
    }

    static func loadArchiveSortMode(
        defaults: UserDefaults = store
    ) -> ArchivedEntrySortMode {
        ArchivedEntrySortMode(
            rawValue: defaults.string(forKey: archiveSortMode) ?? String()
        ) ?? .recentlyArchived
    }

    static func setArchiveSortMode(
        _ value: ArchivedEntrySortMode,
        defaults: UserDefaults = store
    ) {
        defaults.set(value.rawValue, forKey: archiveSortMode)
    }

    static func loadArchiveContentFilter(
        defaults: UserDefaults = store
    ) -> EntryContentFilterMode {
        EntryContentFilterMode(
            rawValue: defaults.string(forKey: archiveContentFilter) ?? String()
        ) ?? .all
    }

    static func setArchiveContentFilter(
        _ value: EntryContentFilterMode,
        defaults: UserDefaults = store
    ) {
        defaults.set(value.rawValue, forKey: archiveContentFilter)
    }

    static func loadTimelineActivityFilter(
        defaults: UserDefaults = store
    ) -> EntryActivityFilterMode {
        EntryActivityFilterMode(
            rawValue: defaults.string(forKey: timelineActivityFilter) ?? String()
        ) ?? .all
    }

    static func setTimelineActivityFilter(
        _ value: EntryActivityFilterMode,
        defaults: UserDefaults = store
    ) {
        defaults.set(value.rawValue, forKey: timelineActivityFilter)
    }

    static func loadTimelineScopeFilter(
        defaults: UserDefaults = store
    ) -> EntryActivityScopeMode {
        EntryActivityScopeMode(
            rawValue: defaults.string(forKey: timelineScopeFilter) ?? String()
        ) ?? .recentSixMonths
    }

    static func setTimelineScopeFilter(
        _ value: EntryActivityScopeMode,
        defaults: UserDefaults = store
    ) {
        defaults.set(value.rawValue, forKey: timelineScopeFilter)
    }
}
