import FluelLibrary
import Foundation
import MHPlatform
import Observation

@MainActor
@Observable
final class ArchiveScreenModel {
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var logger: MHLogger?

    var searchText = String()
    var errorMessage: String?
    var pendingDeleteEntry: Entry?
    var sortMode: ArchivedEntrySortMode {
        didSet {
            EntryListPreferences.setArchiveSortMode(
                sortMode,
                defaults: defaults
            )
            logPreferenceChange(
                name: "sortMode",
                oldValue: oldValue.rawValue,
                newValue: sortMode.rawValue
            )
        }
    }

    var contentFilter: EntryContentFilterMode {
        didSet {
            EntryListPreferences.setArchiveContentFilter(
                contentFilter,
                defaults: defaults
            )
            if contentFilter != .all {
                FluelTipState.markContentFiltersLearned()
            }
            logPreferenceChange(
                name: "contentFilter",
                oldValue: oldValue.rawValue,
                newValue: contentFilter.rawValue
            )
        }
    }

    var hasActiveSearch: Bool {
        searchText.isEmpty == false
    }

    var hasActiveFilter: Bool {
        contentFilter != .all
    }

    init(
        defaults: UserDefaults = EntryListPreferences.store
    ) {
        self.defaults = defaults
        sortMode = EntryListPreferences.loadArchiveSortMode(
            defaults: defaults
        )
        contentFilter = EntryListPreferences.loadArchiveContentFilter(
            defaults: defaults
        )
    }

    func showsContentFiltersTip(
        sortedEntriesCount: Int,
        displayedEntriesCount: Int
    ) -> Bool {
        FluelTipBootstrap.isEnabled
            && FluelTipState.hasLearnedContentFilters == false
            && sortedEntriesCount > 0
            && displayedEntriesCount > 0
    }

    func confirmDelete(
        _ entry: Entry
    ) {
        pendingDeleteEntry = entry
    }

    func dismissDeleteConfirmation() {
        pendingDeleteEntry = nil
    }

    func clearSearch() {
        searchText = String()
    }

    func clearFilter() {
        contentFilter = .all
    }

    func clearError() {
        errorMessage = nil
    }

    func attachLogger(
        _ logger: MHLogger
    ) {
        self.logger = logger
    }

    func handleMutationResult(
        _ result: FluelMutationResult,
        noticeCenter: FluelNoticeCenter
    ) {
        switch result {
        case .success:
            errorMessage = nil
        case let .degradedSuccess(message):
            errorMessage = nil
            noticeCenter.presentWarning(message: message)
        case let .failure(failure):
            errorMessage = failure.message
        }
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
            "Archive preference updated",
            metadata: [
                "setting": name,
                "value": newValue
            ]
        )
    }
}
