import Foundation
@testable import FluelLibrary
import SwiftData
import Testing

struct EntryRepositoryTests {
    private let esES: Locale = .init(identifier: "es_ES")
    private let zhHans: Locale = .init(identifier: "zh-Hans")

    @Test
    func create_roundTrips_day_precision_components() throws {
        let context = try makeTestContext()

        let entry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Wallet",
                precision: .day,
                year: 2_024,
                month: 3,
                day: 8
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: .init(identifier: .gregorian)
        )

        #expect(entry.title == "Wallet")
        #expect(entry.startPrecision == .day)
        #expect(entry.startYear == 2_024)
        #expect(entry.startMonth == 3)
        #expect(entry.startDay == 8)
        #expect(entry.archivedAt == nil)
    }

    @Test
    func create_roundTrips_month_precision_components() throws {
        let context = try makeTestContext()

        let entry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Plant",
                precision: .month,
                year: 2_024,
                month: 9
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: .init(identifier: .gregorian)
        )

        #expect(entry.startPrecision == .month)
        #expect(entry.startYear == 2_024)
        #expect(entry.startMonth == 9)
        #expect(entry.startDay == nil)
    }

    @Test
    func create_roundTrips_year_precision_components() throws {
        let context = try makeTestContext()

        let entry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "This home",
                precision: .year,
                year: 2_018
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: .init(identifier: .gregorian)
        )

        #expect(entry.startPrecision == .year)
        #expect(entry.startYear == 2_018)
        #expect(entry.startMonth == nil)
        #expect(entry.startDay == nil)
    }

    @Test
    func create_rejects_future_month_precision() throws {
        let context = try makeTestContext()

        #expect(throws: EntryRepositoryError.futureStartDate) {
            _ = try EntryRepository.create(
                context: context,
                input: makeInput(
                    title: "Bag",
                    precision: .month,
                    year: 2_026,
                    month: 4
                ),
                now: isoDate("2026-03-08T12:00:00Z"),
                calendar: .init(identifier: .gregorian)
            )
        }
    }

    @Test
    func archive_and_restore_switch_active_and_archived_queries() throws {
        let context = try makeTestContext()
        let entry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Watch",
                precision: .month,
                year: 2_023,
                month: 11
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: .init(identifier: .gregorian)
        )

        #expect(try EntryRepository.fetchActiveEntries(context: context).count == 1)
        #expect(try EntryRepository.fetchArchivedEntries(context: context).isEmpty)

        try EntryRepository.archive(
            context: context,
            entry: entry,
            now: isoDate("2026-03-09T12:00:00Z")
        )

        #expect(try EntryRepository.fetchActiveEntries(context: context).isEmpty)
        #expect(try EntryRepository.fetchArchivedEntries(context: context).count == 1)

        try EntryRepository.restore(
            context: context,
            entry: entry,
            now: isoDate("2026-03-10T12:00:00Z")
        )

        #expect(try EntryRepository.fetchActiveEntries(context: context).count == 1)
        #expect(try EntryRepository.fetchArchivedEntries(context: context).isEmpty)
    }

    @Test
    func delete_removes_archived_entry_without_affecting_other_entries() throws {
        let context = try makeTestContext()
        let archivedEntry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Desk lamp",
                precision: .month,
                year: 2_022,
                month: 8
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: .init(identifier: .gregorian)
        )
        let activeEntry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Wallet",
                precision: .year,
                year: 2_021
            ),
            now: isoDate("2026-03-08T12:00:01Z"),
            calendar: .init(identifier: .gregorian)
        )

        try EntryRepository.archive(
            context: context,
            entry: archivedEntry,
            now: isoDate("2026-03-09T12:00:00Z")
        )

        try EntryRepository.delete(
            context: context,
            entry: archivedEntry
        )

        let remainingEntries = try EntryRepository.fetchAllEntries(
            context: context
        )
        let activeEntries = try EntryRepository.fetchActiveEntries(
            context: context
        )
        let archivedEntries = try EntryRepository.fetchArchivedEntries(
            context: context
        )

        #expect(remainingEntries.count == 1)
        #expect(remainingEntries.first?.title == activeEntry.title)
        #expect(activeEntries.count == 1)
        #expect(activeEntries.first?.title == activeEntry.title)
        #expect(archivedEntries.isEmpty)
    }

    @Test
    func delete_rejects_active_entry() throws {
        let context = try makeTestContext()
        let entry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Shoes",
                precision: .year,
                year: 2_024
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: .init(identifier: .gregorian)
        )

        #expect(throws: EntryRepositoryError.deleteRequiresArchivedEntry) {
            try EntryRepository.delete(
                context: context,
                entry: entry
            )
        }

        #expect(try EntryRepository.fetchAllEntries(context: context).count == 1)
        #expect(try EntryRepository.fetchActiveEntries(context: context).count == 1)
    }

    @Test
    func localizedDescription_formats_spanish_validation_message() {
        let result = EntryRepositoryError.localizedDescription(
            for: .futureStartDate,
            locale: esES
        )

        #expect(result == "La fecha de inicio debe ser hoy o anterior.")
    }

    @Test
    func localizedDescription_formats_chinese_delete_message() {
        let result = EntryRepositoryError.localizedDescription(
            for: .deleteRequiresArchivedEntry,
            locale: zhHans
        )

        #expect(result == "删除前请先将该记录归档。")
    }
}
