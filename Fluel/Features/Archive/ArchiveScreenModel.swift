import FluelLibrary
import Foundation
import Observation

@MainActor
@Observable
final class ArchiveScreenModel {
    @ObservationIgnored private let defaults: UserDefaults

    var searchText = String()
    var errorMessage: String?
    var pendingDeleteEntry: Entry?
    var sortMode: ArchivedEntrySortMode {
        didSet {
            EntryListPreferences.setArchiveSortMode(
                sortMode,
                defaults: defaults
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
}
