import Foundation
@testable import FluelLibrary
import Testing

struct EntryContentFilterTests {
    private let calendar = Calendar(identifier: .gregorian)

    @Test
    func filter_all_keeps_original_entries() throws {
        let entries = try makeEntries()

        let result = EntryContentFilter.filter(
            entries,
            mode: .all
        )

        #expect(result.map(\.title) == ["Wallet", "Bag", "Watch"])
    }

    @Test
    func filter_withNote_keeps_noted_entries_in_original_order() throws {
        let entries = try makeEntries()

        let result = EntryContentFilter.filter(
            entries,
            mode: .withNote
        )

        #expect(result.map(\.title) == ["Wallet", "Watch"])
    }

    @Test
    func filter_withPhoto_keeps_photo_entries_in_original_order() throws {
        let entries = try makeEntries()

        let result = EntryContentFilter.filter(
            entries,
            mode: .withPhoto
        )

        #expect(result.map(\.title) == ["Bag", "Watch"])
    }

    private func makeEntries() throws -> [Entry] {
        let context = try makeTestContext()
        let wallet = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Wallet",
                precision: .year,
                year: 2_020,
                note: "Carries train cards."
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: calendar
        )
        let bag = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Bag",
                precision: .month,
                year: 2_023,
                month: 7,
                photoData: Data([0x01])
            ),
            now: isoDate("2026-03-08T12:00:01Z"),
            calendar: calendar
        )
        let watch = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Watch",
                precision: .day,
                year: 2_024,
                month: 10,
                day: 11,
                photoData: Data([0x02]),
                note: "Weekend trips only."
            ),
            now: isoDate("2026-03-08T12:00:02Z"),
            calendar: calendar
        )

        return [wallet, bag, watch]
    }
}
