@testable import FluelLibrary
import Foundation
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

    @Test
    func filter_matches_english_metadata() throws {
        let context = try makeTestContext()
        let wallet = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Wallet",
                precision: .month,
                year: 2_021,
                month: 4
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: .init(identifier: .gregorian)
        )
        let bag = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Bag",
                precision: .day,
                year: 2_022,
                month: 1,
                day: 3
            ),
            now: isoDate("2026-03-08T12:00:01Z"),
            calendar: .init(identifier: .gregorian)
        )
        let locale = Locale(identifier: "en_US")

        try EntryRepository.archive(
            context: context,
            entry: wallet,
            now: isoDate("2026-03-05T12:00:00Z")
        )

        #expect(
            EntrySearchMatcher.filter(
                [wallet, bag],
                matching: "Known to the month",
                locale: locale
            ).map(\.title) == ["Wallet"]
        )
        #expect(
            EntrySearchMatcher.filter(
                [wallet, bag],
                matching: "Sometime in Apr",
                locale: locale
            ).map(\.title) == ["Wallet"]
        )
        #expect(
            EntrySearchMatcher.filter(
                [wallet, bag],
                matching: "Archived on Mar",
                locale: locale
            ).map(\.title) == ["Wallet"]
        )
    }

    @Test
    func filter_matches_japanese_metadata() throws {
        let context = try makeTestContext()
        let plant = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Plant",
                precision: .year,
                year: 2_018
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: .init(identifier: .gregorian)
        )
        let bag = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Bag",
                precision: .day,
                year: 2_021,
                month: 6,
                day: 1
            ),
            now: isoDate("2026-03-08T12:00:01Z"),
            calendar: .init(identifier: .gregorian)
        )
        let locale = Locale(identifier: "ja_JP")

        try EntryRepository.archive(
            context: context,
            entry: plant,
            now: isoDate("2026-03-05T12:00:00Z")
        )

        #expect(
            EntrySearchMatcher.filter(
                [plant, bag],
                matching: "年まで分かる",
                locale: locale
            ).map(\.title) == ["Plant"]
        )
        #expect(
            EntrySearchMatcher.filter(
                [plant, bag],
                matching: "2018年のどこか",
                locale: locale
            ).map(\.title) == ["Plant"]
        )
        #expect(
            EntrySearchMatcher.filter(
                [plant, bag],
                matching: "保管済み",
                locale: locale
            ).map(\.title) == ["Plant"]
        )
    }
}
