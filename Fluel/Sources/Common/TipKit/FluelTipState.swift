import TipKit

enum FluelTipState {
    @Parameter static var hasLearnedEntryCreation: Bool = false

    @Parameter static var hasLearnedPresetSelection: Bool = false

    @Parameter static var hasLearnedContentFilters: Bool = false

    @Parameter static var hasLearnedTimelineFilters: Bool = false

    @Parameter static var hasLearnedDashboardOverview: Bool = false

    @Parameter static var hasLearnedDetailQuickActions: Bool = false

    @Parameter static var hasLearnedCreatePrecision: Bool = false

    @Parameter static var hasLearnedPresetManagement: Bool = false

    @Parameter static var hasLearnedDefaultPreset: Bool = false

    static func reset() {
        hasLearnedEntryCreation = false
        hasLearnedPresetSelection = false
        hasLearnedContentFilters = false
        hasLearnedTimelineFilters = false
        hasLearnedDashboardOverview = false
        hasLearnedDetailQuickActions = false
        hasLearnedCreatePrecision = false
        hasLearnedPresetManagement = false
        hasLearnedDefaultPreset = false
    }

    static func markEntryCreationLearned() {
        guard FluelTipBootstrap.isEnabled else {
            return
        }

        hasLearnedEntryCreation = true
    }

    static func markPresetSelectionLearned() {
        guard FluelTipBootstrap.isEnabled else {
            return
        }

        hasLearnedPresetSelection = true
    }

    static func markContentFiltersLearned() {
        guard FluelTipBootstrap.isEnabled else {
            return
        }

        hasLearnedContentFilters = true
    }

    static func markTimelineFiltersLearned() {
        guard FluelTipBootstrap.isEnabled else {
            return
        }

        hasLearnedTimelineFilters = true
    }

    static func markDashboardOverviewLearned() {
        guard FluelTipBootstrap.isEnabled else {
            return
        }

        hasLearnedDashboardOverview = true
    }

    static func markDetailQuickActionsLearned() {
        guard FluelTipBootstrap.isEnabled else {
            return
        }

        hasLearnedDetailQuickActions = true
    }

    static func markCreatePrecisionLearned() {
        guard FluelTipBootstrap.isEnabled else {
            return
        }

        hasLearnedCreatePrecision = true
    }

    static func markPresetManagementLearned() {
        guard FluelTipBootstrap.isEnabled else {
            return
        }

        hasLearnedPresetManagement = true
    }

    static func markDefaultPresetLearned() {
        guard FluelTipBootstrap.isEnabled else {
            return
        }

        hasLearnedDefaultPreset = true
    }
}
