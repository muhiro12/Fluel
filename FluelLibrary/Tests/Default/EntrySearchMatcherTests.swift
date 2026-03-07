import Foundation
@testable import FluelLibrary
import Testing

struct EntrySearchMatcherTests {
    @Test
    func filter_returns_original_entries_for_blank_query() throws {
        let context = try makeTestContext()
        let wallet = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Wallet",
                precision: .year,
                year: 2_020
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: .init(identifier: .gregorian)
        )
        let bag = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Bag",
                precision: .year,
                year: 2_021
            ),
            now: isoDate("2026-03-08T12:00:01Z"),
            calendar: .init(identifier: .gregorian)
        )

        let result = EntrySearchMatcher.filter(
            [wallet, bag],
            matching: "   "
        )

        #expect(result.map(\.title) == ["Wallet", "Bag"])
    }

    @Test
    func filter_matches_title_case_insensitively() throws {
        let context = try makeTestContext()
        let wallet = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Wallet",
                precision: .year,
                year: 2_020
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: .init(identifier: .gregorian)
        )
        let bag = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Bag",
                precision: .year,
                year: 2_021
            ),
            now: isoDate("2026-03-08T12:00:01Z"),
            calendar: .init(identifier: .gregorian)
        )

        let result = EntrySearchMatcher.filter(
            [wallet, bag],
            matching: "wall"
        )

        #expect(result.map(\.title) == ["Wallet"])
    }

    @Test
    func filter_matches_notes() throws {
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
            calendar: .init(identifier: .gregorian)
        )
        let bag = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Bag",
                precision: .year,
                year: 2_021,
                note: "Weekend trips only."
            ),
            now: isoDate("2026-03-08T12:00:01Z"),
            calendar: .init(identifier: .gregorian)
        )

        let result = EntrySearchMatcher.filter(
            [wallet, bag],
            matching: "train"
        )

        #expect(result.map(\.title) == ["Wallet"])
    }
}
