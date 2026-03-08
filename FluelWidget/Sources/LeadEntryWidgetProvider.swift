import FluelLibrary
import SwiftData
import WidgetKit

struct LeadEntryWidgetProvider: TimelineProvider {
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
                snapshot: LeadEntryWidgetSnapshotLoader.liveSnapshot()
                    ?? FluelSampleData.placeholderWidgetSnapshot()
            )
        )
    }

    func getTimeline(
        in context: Context,
        completion: @escaping @Sendable (Timeline<LeadEntryWidgetEntry>) -> Void
    ) {
        let entry = LeadEntryWidgetEntry(
            date: .now,
            snapshot: LeadEntryWidgetSnapshotLoader.liveSnapshot()
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
}

private enum LeadEntryWidgetSnapshotLoader {
    static func liveSnapshot() -> EntryWidgetSnapshot? {
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
