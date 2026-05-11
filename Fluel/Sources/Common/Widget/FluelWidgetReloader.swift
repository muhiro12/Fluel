import FluelLibrary
import WidgetKit

enum FluelWidgetReloader {
    static func reloadAllTimelines() {
        WidgetCenter.shared.reloadTimelines(ofKind: FluelWidgetConstants.kind)
    }
}
