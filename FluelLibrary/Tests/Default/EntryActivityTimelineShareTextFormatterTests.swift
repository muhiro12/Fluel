import Foundation
@testable import FluelLibrary
import Testing

struct EntryActivityTimelineShareTextFormatterTests {
    @Test
    func text_includes_summary_trends_and_milestones_in_english() {
        let text = EntryActivityTimelineShareTextFormatter.text(
            summary: .init(
                totalCount: 5,
                displayedCount: 3,
                monthCount: 2,
                addedCount: 1,
                updatedCount: 1,
                archivedCount: 1
            ),
            trends: [
                .init(
                    monthStart: isoDate("2026-03-01T00:00:00Z"),
                    title: "March 2026",
                    totalCount: 2,
                    addedCount: 1,
                    updatedCount: 1,
                    archivedCount: 0
                )
            ],
            milestoneDigest: .init(
                visibleEntryCount: 2,
                milestoneCount: 1,
                approximateCount: 1,
                milestones: [
                    .init(
                        entryID: UUID(),
                        title: "Wallet",
                        milestoneDate: isoDate("2026-03-20T00:00:00Z"),
                        daysRemaining: 12,
                        milestoneText: "2 years",
                        isApproximate: true
                    )
                ]
            ),
            activityFilterLabel: "All",
            scopeLabel: "Recent 6 months",
            locale: Locale(identifier: "en_US")
        )

        #expect(text.contains("Fluel timeline"))
        #expect(text.contains("Showing: 3 of 5 activity items"))
        #expect(text.contains("March 2026: 2 activity items, 1 added, 1 updated, 0 archived"))
        #expect(text.contains("Wallet: 2 years | 12 days left"))
    }

    @Test
    func text_includes_japanese_labels() {
        let text = EntryActivityTimelineShareTextFormatter.text(
            summary: .init(
                totalCount: 4,
                displayedCount: 2,
                monthCount: 1,
                addedCount: 0,
                updatedCount: 1,
                archivedCount: 1
            ),
            trends: [],
            milestoneDigest: .init(
                visibleEntryCount: 1,
                milestoneCount: 0,
                approximateCount: 0,
                milestones: []
            ),
            activityFilterLabel: "保管のみ",
            scopeLabel: "直近6か月",
            locale: Locale(identifier: "ja_JP")
        )

        #expect(text.contains("Fluel タイムライン"))
        #expect(text.contains("絞り込み: 保管のみ"))
        #expect(text.contains("範囲: 直近6か月"))
        #expect(text.contains("表示中: 4件中 2件の動き"))
    }
}
