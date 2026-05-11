import SwiftUI
import TipKit

enum FluelTips {
    struct EntryCreationTip: Tip {
        nonisolated var title: Text {
            Text(FluelCopy.entryCreationTipTitle())
        }

        nonisolated var message: Text? {
            Text(FluelCopy.entryCreationTipBody())
        }

        nonisolated var image: Image? {
            Image(systemName: "plus.circle")
        }

        nonisolated var rules: [Rule] {
            #Rule(FluelTipState.$hasLearnedEntryCreation) { learned in
                learned == false
            }
        }

        nonisolated var options: [any TipOption] {
            MaxDisplayCount(1)
        }
    }

    struct PresetSelectionTip: Tip {
        nonisolated var title: Text {
            Text(FluelCopy.presetSelectionTipTitle())
        }

        nonisolated var message: Text? {
            Text(FluelCopy.presetSelectionTipBody())
        }

        nonisolated var image: Image? {
            Image(systemName: "square.stack.3d.up")
        }

        nonisolated var rules: [Rule] {
            #Rule(FluelTipState.$hasLearnedPresetSelection) { learned in
                learned == false
            }
        }

        nonisolated var options: [any TipOption] {
            MaxDisplayCount(1)
        }
    }

    struct ContentFiltersTip: Tip {
        nonisolated var title: Text {
            Text(FluelCopy.contentFiltersTipTitle())
        }

        nonisolated var message: Text? {
            Text(FluelCopy.contentFiltersTipBody())
        }

        nonisolated var image: Image? {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }

        nonisolated var rules: [Rule] {
            #Rule(FluelTipState.$hasLearnedContentFilters) { learned in
                learned == false
            }
        }

        nonisolated var options: [any TipOption] {
            MaxDisplayCount(1)
        }
    }

    struct TimelineFiltersTip: Tip {
        nonisolated var title: Text {
            Text(FluelCopy.timelineFiltersTipTitle())
        }

        nonisolated var message: Text? {
            Text(FluelCopy.timelineFiltersTipBody())
        }

        nonisolated var image: Image? {
            Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
        }

        nonisolated var rules: [Rule] {
            #Rule(FluelTipState.$hasLearnedTimelineFilters) { learned in
                learned == false
            }
        }

        nonisolated var options: [any TipOption] {
            MaxDisplayCount(1)
        }
    }

    struct DashboardOverviewTip: Tip {
        nonisolated var title: Text {
            Text(FluelCopy.dashboardOverviewTipTitle())
        }

        nonisolated var message: Text? {
            Text(FluelCopy.dashboardOverviewTipBody())
        }

        nonisolated var image: Image? {
            Image(systemName: "chart.bar")
        }

        nonisolated var rules: [Rule] {
            #Rule(FluelTipState.$hasLearnedDashboardOverview) { learned in
                learned == false
            }
        }

        nonisolated var options: [any TipOption] {
            MaxDisplayCount(1)
        }
    }

    struct DetailQuickActionsTip: Tip {
        nonisolated var title: Text {
            Text(FluelCopy.detailQuickActionsTipTitle())
        }

        nonisolated var message: Text? {
            Text(FluelCopy.detailQuickActionsTipBody())
        }

        nonisolated var image: Image? {
            Image(systemName: "square.grid.2x2")
        }

        nonisolated var rules: [Rule] {
            #Rule(FluelTipState.$hasLearnedDetailQuickActions) { learned in
                learned == false
            }
        }

        nonisolated var options: [any TipOption] {
            MaxDisplayCount(1)
        }
    }

    struct CreatePrecisionTip: Tip {
        nonisolated var title: Text {
            Text(FluelCopy.createPrecisionTipTitle())
        }

        nonisolated var message: Text? {
            Text(FluelCopy.createPrecisionTipBody())
        }

        nonisolated var image: Image? {
            Image(systemName: "calendar")
        }

        nonisolated var rules: [Rule] {
            #Rule(FluelTipState.$hasLearnedCreatePrecision) { learned in
                learned == false
            }
        }

        nonisolated var options: [any TipOption] {
            MaxDisplayCount(1)
        }
    }

    struct PresetManagementTip: Tip {
        nonisolated var title: Text {
            Text(FluelCopy.presetManagementTipTitle())
        }

        nonisolated var message: Text? {
            Text(FluelCopy.presetManagementTipBody())
        }

        nonisolated var image: Image? {
            Image(systemName: "pin")
        }

        nonisolated var rules: [Rule] {
            #Rule(FluelTipState.$hasLearnedPresetManagement) { learned in
                learned == false
            }
        }

        nonisolated var options: [any TipOption] {
            MaxDisplayCount(1)
        }
    }

    struct DefaultPresetTip: Tip {
        nonisolated var title: Text {
            Text(FluelCopy.defaultPresetTipTitle())
        }

        nonisolated var message: Text? {
            Text(FluelCopy.defaultPresetTipBody())
        }

        nonisolated var image: Image? {
            Image(systemName: "star")
        }

        nonisolated var rules: [Rule] {
            #Rule(FluelTipState.$hasLearnedDefaultPreset) { learned in
                learned == false
            }
        }

        nonisolated var options: [any TipOption] {
            MaxDisplayCount(1)
        }
    }
}
