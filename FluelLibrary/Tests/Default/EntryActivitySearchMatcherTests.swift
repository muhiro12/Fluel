import Foundation
@testable import FluelLibrary
import Testing

struct EntryActivitySearchMatcherTests {
    @Test
    func filter_returns_original_activity_for_blank_query() {
        let activity = sampleActivity()

        let filtered = EntryActivitySearchMatcher.filter(
            activity,
            matching: "  "
        )

        #expect(filtered == activity)
    }

    @Test
    func filter_matches_title_case_insensitively() {
        let filtered = EntryActivitySearchMatcher.filter(
            sampleActivity(),
            matching: "WALLET"
        )

        #expect(filtered.map(\.title) == ["Wallet"])
    }

    @Test
    func filter_matches_activity_kind_in_english_and_japanese() {
        let english = EntryActivitySearchMatcher.filter(
            sampleActivity(),
            matching: "archive"
        )
        let japanese = EntryActivitySearchMatcher.filter(
            sampleActivity(),
            matching: "更新"
        )

        #expect(english.map(\.title) == ["Desk lamp"])
        #expect(japanese.map(\.title) == ["Plant"])
    }
}

private extension EntryActivitySearchMatcherTests {
    func sampleActivity() -> [EntryActivitySnapshot] {
        [
            .init(
                entryID: UUID(),
                title: "Wallet",
                kind: .added,
                timestamp: isoDate("2026-03-08T12:00:00Z")
            ),
            .init(
                entryID: UUID(),
                title: "Desk lamp",
                kind: .archived,
                timestamp: isoDate("2026-03-08T11:00:00Z")
            ),
            .init(
                entryID: UUID(),
                title: "Plant",
                kind: .updated,
                timestamp: isoDate("2026-03-08T10:00:00Z")
            ),
        ]
    }
}
