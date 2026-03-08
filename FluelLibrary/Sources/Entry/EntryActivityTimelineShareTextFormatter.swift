import Foundation

/// Shared share-sheet text generator for the current timeline view.
public enum EntryActivityTimelineShareTextFormatter {
    public static func text(
        summary: EntryActivityTimelineSummary,
        trends: [EntryActivityTrendSnapshot],
        milestoneDigest: EntryTimelineMilestoneDigest,
        activityFilterLabel: String,
        scopeLabel: String,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        var lines = [
            localized(
                english: "Fluel timeline",
                japanese: "Fluel タイムライン",
                locale: locale
            ),
            labeledLine(
                title: localized(
                    english: "Filter",
                    japanese: "絞り込み",
                    locale: locale
                ),
                value: activityFilterLabel
            ),
            labeledLine(
                title: localized(
                    english: "Scope",
                    japanese: "範囲",
                    locale: locale
                ),
                value: scopeLabel
            ),
            localized(
                english: "Timeline summary",
                japanese: "タイムライン要約",
                locale: locale
            ),
            labeledLine(
                title: localized(
                    english: "Showing",
                    japanese: "表示中",
                    locale: locale
                ),
                value: localized(
                    english: "\(summary.displayedCount) of \(summary.totalCount) activity items",
                    japanese: "\(summary.totalCount)件中 \(summary.displayedCount)件の動き",
                    locale: locale
                )
            ),
            labeledLine(
                title: localized(
                    english: "Months",
                    japanese: "月数",
                    locale: locale
                ),
                value: localized(
                    english: "\(summary.monthCount) months",
                    japanese: "\(summary.monthCount)か月",
                    locale: locale
                )
            ),
            labeledLine(
                title: localized(
                    english: "Added",
                    japanese: "追加",
                    locale: locale
                ),
                value: summary.addedCount.formatted()
            ),
            labeledLine(
                title: localized(
                    english: "Updated",
                    japanese: "更新",
                    locale: locale
                ),
                value: summary.updatedCount.formatted()
            ),
            labeledLine(
                title: localized(
                    english: "Archived",
                    japanese: "保管",
                    locale: locale
                ),
                value: summary.archivedCount.formatted()
            ),
        ]

        if trends.isEmpty == false {
            lines.append(String())
            lines.append(
                localized(
                    english: "Monthly trends",
                    japanese: "月ごとの動き",
                    locale: locale
                )
            )

            lines.append(
                contentsOf: trends.map { trend in
                    "\(trend.title): \(localizedTrendTotal(trend.totalCount, locale: locale)), \(localizedTrendKinds(trend: trend, locale: locale))"
                }
            )
        }

        if milestoneDigest.milestones.isEmpty == false {
            lines.append(String())
            lines.append(
                localized(
                    english: "Upcoming from this timeline",
                    japanese: "このタイムラインの次の節目",
                    locale: locale
                )
            )
            lines.append(
                labeledLine(
                    title: localized(
                        english: "Visible entries",
                        japanese: "表示中の記録",
                        locale: locale
                    ),
                    value: milestoneDigest.visibleEntryCount.formatted()
                )
            )

            if milestoneDigest.approximateCount > 0 {
                lines.append(
                    labeledLine(
                        title: localized(
                            english: "Approximate milestones",
                            japanese: "おおよその節目",
                            locale: locale
                        ),
                        value: milestoneDigest.approximateCount.formatted()
                    )
                )
            }

            lines.append(
                contentsOf: milestoneDigest.milestones.map { milestone in
                    "\(milestone.title): \(localizedMilestone(milestone, locale: locale))"
                }
            )
        }

        return lines.joined(separator: "\n")
    }
}

private extension EntryActivityTimelineShareTextFormatter {
    static func labeledLine(
        title: String,
        value: String
    ) -> String {
        "\(title): \(value)"
    }

    static func localizedTrendTotal(
        _ count: Int,
        locale: Locale
    ) -> String {
        localized(
            english: "\(count) activity items",
            japanese: "動き \(count)件",
            locale: locale
        )
    }

    static func localizedTrendKinds(
        trend: EntryActivityTrendSnapshot,
        locale: Locale
    ) -> String {
        [
            localized(
                english: "\(trend.addedCount) added",
                japanese: "追加 \(trend.addedCount)件",
                locale: locale
            ),
            localized(
                english: "\(trend.updatedCount) updated",
                japanese: "更新 \(trend.updatedCount)件",
                locale: locale
            ),
            localized(
                english: "\(trend.archivedCount) archived",
                japanese: "保管 \(trend.archivedCount)件",
                locale: locale
            ),
        ]
        .joined(separator: ", ")
    }

    static func localizedMilestone(
        _ milestone: EntryMilestoneSnapshot,
        locale: Locale
    ) -> String {
        let daysText = localized(
            english: "\(milestone.daysRemaining) days left",
            japanese: "あと\(milestone.daysRemaining)日",
            locale: locale
        )
        let approximateText = milestone.isApproximate
            ? localized(
                english: "approximate",
                japanese: "おおよそ",
                locale: locale
            )
            : nil

        return [
            milestone.milestoneText,
            daysText,
            milestone.milestoneDate.formatted(
                .dateTime
                    .locale(locale)
                    .year()
                    .month(.abbreviated)
                    .day()
            ),
            approximateText
        ]
        .compactMap { $0 }
        .joined(separator: " | ")
    }

    static func localized(
        english: String,
        japanese: String,
        locale: Locale
    ) -> String {
        switch FluelLocale(locale: locale) {
        case .english:
            return english
        case .japanese:
            return japanese
        }
    }
}
