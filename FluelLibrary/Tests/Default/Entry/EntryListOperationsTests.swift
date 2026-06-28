import Foundation
import Testing

import FluelLibrary

struct EntryListOperationsTests {
    private struct Values {
        let title: String
        let note: String?
        let hasPhoto: Bool
        let startYear: Int
        let updatedDay: Int
        let archivedDay: Int?
    }

    private var activeFixtures: [Values] {
        [
            .init(
                title: "Notebook",
                note: "Ordinary thoughts",
                hasPhoto: false,
                startYear: 2_024,
                updatedDay: 3,
                archivedDay: nil
            ),
            .init(
                title: "Watch",
                note: nil,
                hasPhoto: true,
                startYear: 2_025,
                updatedDay: 4,
                archivedDay: nil
            ),
            .init(
                title: "This home",
                note: nil,
                hasPhoto: false,
                startYear: 2_021,
                updatedDay: 2,
                archivedDay: nil
            ),
            .init(
                title: "Desk lamp",
                note: "Moved to storage",
                hasPhoto: false,
                startYear: 2_020,
                updatedDay: 5,
                archivedDay: 6
            )
        ]
    }

    private var archivedFixtures: [Values] {
        [
            .init(
                title: "Desk lamp",
                note: "Moved to storage",
                hasPhoto: false,
                startYear: 2_020,
                updatedDay: 6,
                archivedDay: 6
            ),
            .init(
                title: "Bag",
                note: nil,
                hasPhoto: true,
                startYear: 2_024,
                updatedDay: 4,
                archivedDay: 4
            ),
            .init(
                title: "Wallet",
                note: nil,
                hasPhoto: false,
                startYear: 2_026,
                updatedDay: 3,
                archivedDay: nil
            )
        ]
    }

    @Test
    func activeEntriesApplySearchFilterAndSort() {
        let calendar = TestDateSupport.calendar
        let snapshots = activeFixtures.map { values in
            snapshot(values, calendar: calendar)
        }

        let longestTogether = EntryOperations.activeEntries(
            from: snapshots,
            sort: .longestTogether,
            calendar: calendar
        )
        let mostRecentStart = EntryOperations.activeEntries(
            from: snapshots,
            sort: .mostRecentStart,
            calendar: calendar
        )
        let noteMatches = EntryOperations.activeEntries(
            from: snapshots,
            searchText: "thoughts",
            filter: .withNote,
            sort: .alphabetical,
            calendar: calendar
        )
        let photoMatches = EntryOperations.activeEntries(
            from: snapshots,
            filter: .withPhoto,
            sort: .alphabetical,
            calendar: calendar
        )

        #expect(longestTogether.map(\.title) == ["This home", "Notebook", "Watch"])
        #expect(mostRecentStart.map(\.title) == ["Watch", "Notebook", "This home"])
        #expect(noteMatches.map(\.title) == ["Notebook"])
        #expect(photoMatches.map(\.title) == ["Watch"])
    }

    @Test
    func archivedEntriesApplySearchFilterAndSort() {
        let calendar = TestDateSupport.calendar
        let snapshots = archivedFixtures.map { values in
            snapshot(values, calendar: calendar)
        }

        let recentlyArchived = EntryOperations.archivedEntries(
            from: snapshots,
            sort: .recentlyArchived,
            calendar: calendar
        )
        let oldestArchived = EntryOperations.archivedEntries(
            from: snapshots,
            sort: .oldestArchived,
            calendar: calendar
        )
        let longestBeforeArchive = EntryOperations.archivedEntries(
            from: snapshots,
            sort: .longestTogetherBeforeArchive,
            calendar: calendar
        )
        let noteMatches = EntryOperations.archivedEntries(
            from: snapshots,
            searchText: "storage",
            filter: .withNote,
            sort: .alphabetical,
            calendar: calendar
        )
        let photoMatches = EntryOperations.archivedEntries(
            from: snapshots,
            filter: .withPhoto,
            sort: .alphabetical,
            calendar: calendar
        )

        #expect(recentlyArchived.map(\.title) == ["Desk lamp", "Bag"])
        #expect(oldestArchived.map(\.title) == ["Bag", "Desk lamp"])
        #expect(longestBeforeArchive.map(\.title) == ["Desk lamp", "Bag"])
        #expect(noteMatches.map(\.title) == ["Desk lamp"])
        #expect(photoMatches.map(\.title) == ["Bag"])
    }

    private func snapshot(_ values: Values, calendar: Calendar) -> EntrySnapshot {
        EntrySnapshot(
            id: UUID(),
            title: values.title,
            startDate: TestDateSupport.date(year: values.startYear, month: 1, day: 1),
            startPrecision: .year,
            createdAt: TestDateSupport.date(year: 2_026, month: 6, day: 1),
            updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: values.updatedDay),
            archivedAt: values.archivedDay.map { day in
                TestDateSupport.date(year: 2_026, month: 6, day: day)
            },
            note: values.note,
            hasPhoto: values.hasPhoto,
            calendar: calendar
        )
    }
}
