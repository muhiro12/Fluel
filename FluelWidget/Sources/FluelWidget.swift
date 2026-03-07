import FluelLibrary
import SwiftData
import SwiftUI
import WidgetKit

private struct LeadEntryWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: EntryWidgetSnapshot?
}

private struct LeadEntryWidgetProvider: TimelineProvider {
    func placeholder(
        in context: Context
    ) -> LeadEntryWidgetEntry {
        .init(
            date: .now,
            snapshot: FluelSampleData.placeholderWidgetSnapshot()
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping @Sendable (LeadEntryWidgetEntry) -> Void
    ) {
        completion(
            .init(
                date: .now,
                snapshot: liveSnapshot() ?? FluelSampleData.placeholderWidgetSnapshot()
            )
        )
    }

    func getTimeline(
        in context: Context,
        completion: @escaping @Sendable (Timeline<LeadEntryWidgetEntry>) -> Void
    ) {
        let entry = LeadEntryWidgetEntry(
            date: .now,
            snapshot: liveSnapshot()
        )
        let refreshDate = Calendar.autoupdatingCurrent.nextDate(
            after: .now,
            matching: .init(hour: 0, minute: 5),
            matchingPolicy: .nextTime
        ) ?? .now.addingTimeInterval(21_600) // swiftlint:disable:this no_magic_numbers

        completion(
            .init(
                entries: [entry],
                policy: .after(refreshDate)
            )
        )
    }

    private func liveSnapshot() -> EntryWidgetSnapshot? {
        do {
            let container = try ModelContainerFactory.shared()

            return try EntryWidgetSnapshotQuery.snapshot(
                context: container.mainContext
            )
        } catch {
            assertionFailure("Widget failed to load shared snapshot: \(error)")
            return nil
        }
    }
}

private struct LeadEntryWidgetView: View {
    let entry: LeadEntryWidgetEntry

    var body: some View {
        Group {
            if let snapshot = entry.snapshot {
                VStack(alignment: .leading, spacing: 10) {
                    Text(snapshot.title)
                        .font(.headline.weight(.medium))
                        .lineLimit(2)

                    Spacer(minLength: 0)

                    Text(snapshot.primaryText)
                        .font(.title3.weight(.semibold))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    Text(snapshot.startText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)

                    Text(
                        EntryFormatting.activeCountText(
                            snapshot.activeCount
                        )
                    )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(16)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text(widgetEmptyTitle)
                        .font(.headline.weight(.medium))

                    Text(widgetEmptyBody)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(16)
            }
        }
        .containerBackground(.background, for: .widget)
    }

    private var widgetEmptyTitle: String {
        localized(
            english: "Nothing yet",
            japanese: "まだありません"
        )
    }

    private var widgetEmptyBody: String {
        localized(
            english: "Add an entry in Fluel to quietly keep time with it.",
            japanese: "Fluel で記録を追加すると、その時間が静かに見えてきます。"
        )
    }

    private func localized(
        english: String,
        japanese: String
    ) -> String {
        let languageIdentifier = Locale.autoupdatingCurrent.language.languageCode?.identifier ?? Locale.autoupdatingCurrent.identifier

        if languageIdentifier.hasPrefix("ja") {
            return japanese
        }

        return english
    }
}

struct LeadEntryWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: FluelWidgetConstants.kind,
            provider: LeadEntryWidgetProvider()
        ) { entry in
            LeadEntryWidgetView(entry: entry)
        }
        .configurationDisplayName("Fluel")
        .description(widgetDescription)
        .supportedFamilies([.systemSmall])
    }

    private var widgetDescription: String {
        let languageIdentifier = Locale.autoupdatingCurrent.language.languageCode?.identifier ?? Locale.autoupdatingCurrent.identifier

        if languageIdentifier.hasPrefix("ja") {
            return "いちばん長く一緒にいる記録を静かに表示します。"
        }

        return "Shows the entry you have been living with the longest."
    }
}

@main
struct FluelWidgetBundle: WidgetBundle {
    var body: some Widget {
        LeadEntryWidget()
    }
}
