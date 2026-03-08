import FluelLibrary
import SwiftUI
import WidgetKit

struct LeadEntryWidget: Widget {
    private let copy = LeadEntryWidgetLocalization()

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: FluelWidgetConstants.kind,
            provider: LeadEntryWidgetProvider()
        ) { entry in
            LeadEntryWidgetView(entry: entry)
        }
        .configurationDisplayName("Fluel")
        .description(copy.widgetDescription)
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
