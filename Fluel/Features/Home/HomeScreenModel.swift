import FluelLibrary
import Foundation
import Observation

@MainActor
@Observable
final class HomeScreenModel {
    enum TipKind {
        case addEntry
        case presets
        case filters
    }

    @ObservationIgnored private let defaults: UserDefaults

    var searchText = String()
    var errorMessage: String?
    var sortMode: ActiveEntrySortMode {
        didSet {
            EntryListPreferences.setHomeSortMode(
                sortMode,
                defaults: defaults
            )
        }
    }

    var contentFilter: EntryContentFilterMode {
        didSet {
            EntryListPreferences.setHomeContentFilter(
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
        sortMode = EntryListPreferences.loadHomeSortMode(
            defaults: defaults
        )
        contentFilter = EntryListPreferences.loadHomeContentFilter(
            defaults: defaults
        )
    }

    func currentTip(
        hasQuickPresets: Bool,
        sortedEntriesCount: Int,
        displayedEntriesCount: Int
    ) -> TipKind? {
        guard FluelTipBootstrap.isEnabled else {
            return nil
        }

        if FluelTipState.hasLearnedEntryCreation == false {
            return .addEntry
        }

        if hasQuickPresets,
           FluelTipState.hasLearnedPresetSelection == false {
            return .presets
        }

        if sortedEntriesCount > 0,
           displayedEntriesCount > 0,
           FluelTipState.hasLearnedContentFilters == false {
            return .filters
        }

        return nil
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
