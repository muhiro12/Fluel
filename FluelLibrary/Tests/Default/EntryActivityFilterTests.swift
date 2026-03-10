@testable import FluelLibrary
import Foundation
import Testing

struct EntryActivityFilterTests {
    @Test
    func filter_all_keeps_original_order() {
        let activity = sampleActivity()

        let filtered = EntryActivityFilter.filter(
            activity,
            mode: .all
        )

        #expect(filtered == activity)
    }

    @Test
    func filter_archived_keeps_only_archived_activity() {
        let filtered = EntryActivityFilter.filter(
            sampleActivity(),
            mode: .archived
        )

        #expect(filtered.map(\.title) == ["Desk lamp"])
        #expect(filtered.allSatisfy { $0.kind == .archived })
    }

    @Test
    func filter_updated_returns_matching_activity_in_original_order() {
        let filtered = EntryActivityFilter.filter(
            sampleActivity(),
            mode: .updated
        )

        #expect(filtered.map(\.title) == ["Wallet", "Plant"])
        #expect(filtered.allSatisfy { $0.kind == .updated })
    }
}

private extension EntryActivityFilterTests {
    func sampleActivity() -> [EntryActivitySnapshot] {
        [
            .init(
                entryID: UUID(),
                title: "Wallet",
                kind: .updated,
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
            .init(
                entryID: UUID(),
                title: "Shoes",
                kind: .added,
                timestamp: isoDate("2026-03-08T09:00:00Z")
            )
        ]
    }
}
