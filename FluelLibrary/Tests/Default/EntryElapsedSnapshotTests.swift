@testable import FluelLibrary
import Foundation
import Testing

struct EntryElapsedSnapshotTests {
    @Test
    func dayPrecision_returns_zero_on_same_day() throws {
        let snapshot = EntryElapsedSnapshot(
            startComponents: try .init(
                precision: .day,
                year: 2_026,
                month: 3,
                day: 8
            ),
            referenceDate: isoDate("2026-03-08T12:00:00Z"),
            calendar: .init(identifier: .gregorian)
        )

        #expect(snapshot.years == 0)
        #expect(snapshot.months == 0)
        #expect(snapshot.days == 0)
        #expect(snapshot.totalDays == 0)
    }

    @Test
    func dayPrecision_handles_month_boundary() throws {
        let snapshot = EntryElapsedSnapshot(
            startComponents: try .init(
                precision: .day,
                year: 2_024,
                month: 2,
                day: 29
            ),
            referenceDate: isoDate("2024-03-01T12:00:00Z"),
            calendar: .init(identifier: .gregorian)
        )

        #expect(snapshot.years == 0)
        #expect(snapshot.months == 0)
        #expect(snapshot.days == 1)
        #expect(snapshot.totalDays == 1)
    }

    @Test
    func monthPrecision_never_emits_days() throws {
        let snapshot = EntryElapsedSnapshot(
            startComponents: try .init(
                precision: .month,
                year: 2_024,
                month: 12
            ),
            referenceDate: isoDate("2025-01-28T12:00:00Z"),
            calendar: .init(identifier: .gregorian)
        )

        #expect(snapshot.years == 0)
        #expect(snapshot.months == 1)
        #expect(snapshot.days == 0)
        #expect(snapshot.totalMonths == 1)
        #expect(snapshot.totalDays == nil)
    }

    @Test
    func yearPrecision_never_emits_months_or_days() throws {
        let snapshot = EntryElapsedSnapshot(
            startComponents: try .init(
                precision: .year,
                year: 2_021
            ),
            referenceDate: isoDate("2026-03-08T12:00:00Z"),
            calendar: .init(identifier: .gregorian)
        )

        #expect(snapshot.years == 5)
        #expect(snapshot.months == 0)
        #expect(snapshot.days == 0)
        #expect(snapshot.totalMonths == nil)
        #expect(snapshot.totalDays == nil)
    }
}
