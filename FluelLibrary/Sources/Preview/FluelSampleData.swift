import Foundation
import SwiftData
import SwiftUI

/// In-memory preview data and sample entry seeding.
public struct FluelSampleData: PreviewModifier {
    public struct Context {
        public let modelContainer: ModelContainer
    }

    public init() {
        // no-op
    }

    public static func makeSharedContext() throws -> Context {
        let modelContainer = try ModelContainerFactory.inMemory()

        try seed(
            context: modelContainer.mainContext,
            ifEmptyOnly: true
        )

        return .init(
            modelContainer: modelContainer
        )
    }

    public func body(content: Content, context: Context) -> some View {
        content
            .modelContainer(context.modelContainer)
    }
}

public extension FluelSampleData {
    static func seed(
        context: ModelContext,
        now: Date = .now,
        ifEmptyOnly: Bool = false
    ) throws {
        if ifEmptyOnly,
           try context.fetchCount(FetchDescriptor<Entry>()) > 0 {
            return
        }

        let calendar = Calendar.autoupdatingCurrent
        let sampleInputs = previewInputs(
            referenceDate: now,
            calendar: calendar
        )

        for (index, input) in sampleInputs.enumerated() {
            let entry = try Entry.create(
                context: context,
                input: input,
                now: now.addingTimeInterval(Double(index)),
                calendar: calendar
            )

            if input.title == "Desk lamp" {
                entry.archive(
                    now: calendar.date(
                        byAdding: .day,
                        value: -18,
                        to: now
                    ) ?? now
                )
            }
        }

        try context.save()
    }

    static func placeholderWidgetSnapshot(
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent
    ) -> EntryWidgetSnapshot {
        EntryWidgetSnapshotQuery.placeholder(
            locale: locale,
            calendar: calendar
        )
    }
}

private extension FluelSampleData {
    static func previewInputs(
        referenceDate: Date,
        calendar: Calendar
    ) -> [EntryFormInput] {
        func dayInput(
            title: String,
            daysAgo: Int,
            note: String? = nil
        ) -> EntryFormInput {
            let date = calendar.date(
                byAdding: .day,
                value: -daysAgo,
                to: referenceDate
            ) ?? referenceDate

            return .init(
                title: title,
                startPrecision: .day,
                startYear: calendar.component(.year, from: date),
                startMonth: calendar.component(.month, from: date),
                startDay: calendar.component(.day, from: date),
                note: note
            )
        }

        func monthInput(
            title: String,
            monthsAgo: Int,
            note: String? = nil
        ) -> EntryFormInput {
            let date = calendar.date(
                byAdding: .month,
                value: -monthsAgo,
                to: referenceDate
            ) ?? referenceDate

            return .init(
                title: title,
                startPrecision: .month,
                startYear: calendar.component(.year, from: date),
                startMonth: calendar.component(.month, from: date),
                note: note
            )
        }

        func yearInput(
            title: String,
            yearsAgo: Int,
            note: String? = nil
        ) -> EntryFormInput {
            let date = calendar.date(
                byAdding: .year,
                value: -yearsAgo,
                to: referenceDate
            ) ?? referenceDate

            return .init(
                title: title,
                startPrecision: .year,
                startYear: calendar.component(.year, from: date),
                note: note
            )
        }

        return [
            yearInput(
                title: "This home",
                yearsAgo: 8,
                note: "Quietly holding daily life together."
            ),
            yearInput(
                title: "Furniture",
                yearsAgo: 6,
                note: "The table that has stayed through different rooms."
            ),
            monthInput(
                title: "Watch",
                monthsAgo: 41
            ),
            dayInput(
                title: "Wallet",
                daysAgo: 634,
                note: "Always in the same pocket."
            ),
            monthInput(
                title: "Bag",
                monthsAgo: 17
            ),
            dayInput(
                title: "Shoes",
                daysAgo: 96
            ),
            dayInput(
                title: "Notebook",
                daysAgo: 42,
                note: "Mostly for ordinary thoughts."
            ),
            monthInput(
                title: "Plant",
                monthsAgo: 7
            ),
            dayInput(
                title: "Desk lamp",
                daysAgo: 251
            )
        ]
    }
}
