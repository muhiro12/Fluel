@testable import FluelLibrary
import Foundation
import Testing

struct EntryTimelineMilestoneDigestQueryTests {
    @Test
    func digest_uses_visible_active_entries_and_counts_approximate_milestones() throws {
        let context = try makeTestContext()
        let calendar = Calendar(identifier: .gregorian)
        let referenceDate = isoDate("2026-03-08T12:00:00Z")

        let wallet = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Wallet",
                precision: .day,
                year: 2_024,
                month: 3,
                day: 20
            ),
            now: referenceDate,
            calendar: calendar
        )
        let watch = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Watch",
                precision: .month,
                year: 2_023,
                month: 6
            ),
            now: isoDate("2026-03-08T12:00:01Z"),
            calendar: calendar
        )
        let lamp = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Lamp",
                precision: .day,
                year: 2_021,
                month: 1,
                day: 1
            ),
            now: isoDate("2026-03-08T12:00:02Z"),
            calendar: calendar
        )

        try EntryRepository.archive(
            context: context,
            entry: lamp,
            now: isoDate("2026-03-08T12:30:00Z")
        )

        let digest = EntryTimelineMilestoneDigestQuery.digest(
            entries: [wallet, watch, lamp],
            visibleActivity: [
                .init(
                    entryID: wallet.id,
                    title: wallet.title,
                    kind: .updated,
                    timestamp: referenceDate
                ),
                .init(
                    entryID: watch.id,
                    title: watch.title,
                    kind: .added,
                    timestamp: referenceDate
                ),
                .init(
                    entryID: lamp.id,
                    title: lamp.title,
                    kind: .archived,
                    timestamp: referenceDate
                )
            ],
            referenceDate: referenceDate,
            locale: Locale(identifier: "en_US"),
            calendar: calendar,
            limit: 5
        )

        #expect(digest.visibleEntryCount == 3)
        #expect(digest.milestoneCount == 2)
        #expect(digest.approximateCount == 1)
        #expect(digest.milestones.map(\.title) == ["Wallet", "Watch"])
    }

    @Test
    func digest_applies_limit_to_visible_milestones() throws {
        let context = try makeTestContext()
        let calendar = Calendar(identifier: .gregorian)
        let referenceDate = isoDate("2026-03-08T12:00:00Z")

        let a = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "A",
                precision: .day,
                year: 2_024,
                month: 3,
                day: 9
            ),
            now: referenceDate,
            calendar: calendar
        )
        let b = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "B",
                precision: .day,
                year: 2_024,
                month: 3,
                day: 10
            ),
            now: isoDate("2026-03-08T12:00:01Z"),
            calendar: calendar
        )

        let digest = EntryTimelineMilestoneDigestQuery.digest(
            entries: [a, b],
            visibleActivity: [
                .init(entryID: a.id, title: a.title, kind: .added, timestamp: referenceDate),
                .init(entryID: b.id, title: b.title, kind: .updated, timestamp: referenceDate)
            ],
            referenceDate: referenceDate,
            calendar: calendar,
            limit: 1
        )

        #expect(digest.milestoneCount == 1)
        #expect(digest.milestones.first?.title == "A")
    }
}
