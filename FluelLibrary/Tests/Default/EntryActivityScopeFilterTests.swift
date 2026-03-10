@testable import FluelLibrary
import Foundation
import Testing

struct EntryActivityScopeFilterTests {
    private let calendar = Calendar(identifier: .gregorian)
    private let referenceDate = isoDate("2026-03-15T12:00:00Z")

    @Test
    func recentSixMonths_keeps_activity_from_current_window() {
        let filtered = EntryActivityScopeFilter.filter(
            sampleActivity(),
            mode: .recentSixMonths,
            referenceDate: referenceDate,
            calendar: calendar
        )

        #expect(filtered.map(\.title) == ["Phone", "Shelf", "Plant"])
    }

    @Test
    func recentYear_keeps_last_twelve_months() {
        let filtered = EntryActivityScopeFilter.filter(
            sampleActivity(),
            mode: .recentYear,
            referenceDate: referenceDate,
            calendar: calendar
        )

        #expect(filtered.map(\.title) == ["Phone", "Shelf", "Plant", "Bike"])
    }

    @Test
    func allTime_keeps_original_activity() {
        let activity = sampleActivity()

        let filtered = EntryActivityScopeFilter.filter(
            activity,
            mode: .allTime,
            referenceDate: referenceDate,
            calendar: calendar
        )

        #expect(filtered == activity)
    }
}

private extension EntryActivityScopeFilterTests {
    func sampleActivity() -> [EntryActivitySnapshot] {
        [
            .init(
                entryID: UUID(),
                title: "Phone",
                kind: .updated,
                timestamp: isoDate("2026-03-10T09:00:00Z")
            ),
            .init(
                entryID: UUID(),
                title: "Shelf",
                kind: .added,
                timestamp: isoDate("2025-12-04T09:00:00Z")
            ),
            .init(
                entryID: UUID(),
                title: "Plant",
                kind: .archived,
                timestamp: isoDate("2025-10-20T09:00:00Z")
            ),
            .init(
                entryID: UUID(),
                title: "Bike",
                kind: .updated,
                timestamp: isoDate("2025-04-14T09:00:00Z")
            ),
            .init(
                entryID: UUID(),
                title: "Lamp",
                kind: .added,
                timestamp: isoDate("2024-11-01T09:00:00Z")
            )
        ]
    }
}
