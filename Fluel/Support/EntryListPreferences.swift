import Foundation

enum EntryListPreferences {
    static let store = FluelSharedPreferences.store

    static let homeSortMode = "home_list_sort_mode"
    static let homeContentFilter = "home_list_content_filter"
    static let archiveSortMode = "archive_list_sort_mode"
    static let archiveContentFilter = "archive_list_content_filter"
    static let timelineActivityFilter = "timeline_activity_filter"
    static let timelineScopeFilter = "timeline_scope_filter"
}
