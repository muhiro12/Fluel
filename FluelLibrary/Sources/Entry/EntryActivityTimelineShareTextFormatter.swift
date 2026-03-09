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
                value: localizedSummaryActivityCount(
                    summary: summary,
                    locale: locale
                )
            ),
            labeledLine(
                title: localized(
                    english: "Months",
                    japanese: "月数",
                    locale: locale
                ),
                value: localizedSummaryMonthCount(
                    summary.monthCount,
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
        let number = count.formatted(
            .number
                .locale(locale)
        )

        switch FluelLocale(locale: locale) {
        case .english:
            return count == 1 ? "\(number) activity item" : "\(number) activity items"
        case .japanese:
            return "動き \(number)件"
        case .spanish:
            return count == 1 ? "\(number) actividad" : "\(number) actividades"
        case .french:
            return count == 1 ? "\(number) activité" : "\(number) activités"
        case .simplifiedChinese:
            return "\(number) 条动态"
        }
    }

    static func localizedSummaryActivityCount(
        summary: EntryActivityTimelineSummary,
        locale: Locale
    ) -> String {
        let displayed = summary.displayedCount.formatted(
            .number
                .locale(locale)
        )
        let total = summary.totalCount.formatted(
            .number
                .locale(locale)
        )

        switch FluelLocale(locale: locale) {
        case .english:
            return "\(displayed) of \(total) activity items"
        case .japanese:
            return "\(total)件中 \(displayed)件の動き"
        case .spanish:
            return "\(displayed) de \(total) actividades"
        case .french:
            return "\(displayed) activités sur \(total)"
        case .simplifiedChinese:
            return "\(total) 条动态中的 \(displayed) 条"
        }
    }

    static func localizedSummaryMonthCount(
        _ count: Int,
        locale: Locale
    ) -> String {
        let number = count.formatted(
            .number
                .locale(locale)
        )

        switch FluelLocale(locale: locale) {
        case .english:
            return count == 1 ? "\(number) month" : "\(number) months"
        case .japanese:
            return "\(number)か月"
        case .spanish:
            return count == 1 ? "\(number) mes" : "\(number) meses"
        case .french:
            return "\(number) mois"
        case .simplifiedChinese:
            return "\(number)个月"
        }
    }

    static func localizedTrendKinds(
        trend: EntryActivityTrendSnapshot,
        locale: Locale
    ) -> String {
        [
            localizedTrendKind(
                kind: .added,
                count: trend.addedCount,
                locale: locale
            ),
            localizedTrendKind(
                kind: .updated,
                count: trend.updatedCount,
                locale: locale
            ),
            localizedTrendKind(
                kind: .archived,
                count: trend.archivedCount,
                locale: locale
            ),
        ]
        .joined(separator: ", ")
    }

    static func localizedMilestone(
        _ milestone: EntryMilestoneSnapshot,
        locale: Locale
    ) -> String {
        let number = milestone.daysRemaining.formatted(
            .number
                .locale(locale)
        )
        let daysText: String
        switch FluelLocale(locale: locale) {
        case .english:
            daysText = milestone.daysRemaining == 1 ? "\(number) day left" : "\(number) days left"
        case .japanese:
            daysText = "あと\(number)日"
        case .spanish:
            daysText = milestone.daysRemaining == 1 ? "Queda \(number) día" : "Quedan \(number) días"
        case .french:
            daysText = milestone.daysRemaining == 1 ? "Encore \(number) jour" : "Encore \(number) jours"
        case .simplifiedChinese:
            daysText = "还有\(number)天"
        }
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

    static func localizedTrendKind(
        kind: EntryActivityKind,
        count: Int,
        locale: Locale
    ) -> String {
        let number = count.formatted(
            .number
                .locale(locale)
        )

        switch (kind, FluelLocale(locale: locale)) {
        case (.added, .english):
            return "\(number) added"
        case (.added, .japanese):
            return "追加 \(number)件"
        case (.added, .spanish):
            return "\(number) añadidas"
        case (.added, .french):
            return count == 1 ? "\(number) ajout" : "\(number) ajouts"
        case (.added, .simplifiedChinese):
            return "新增 \(number) 项"
        case (.updated, .english):
            return "\(number) updated"
        case (.updated, .japanese):
            return "更新 \(number)件"
        case (.updated, .spanish):
            return "\(number) actualizadas"
        case (.updated, .french):
            return count == 1 ? "\(number) mise à jour" : "\(number) mises à jour"
        case (.updated, .simplifiedChinese):
            return "更新 \(number) 项"
        case (.archived, .english):
            return "\(number) archived"
        case (.archived, .japanese):
            return "保管 \(number)件"
        case (.archived, .spanish):
            return "\(number) archivadas"
        case (.archived, .french):
            return count == 1 ? "\(number) archivage" : "\(number) archivages"
        case (.archived, .simplifiedChinese):
            return "归档 \(number) 项"
        }
    }

    static func localized(
        english: String,
        japanese: String,
        locale: Locale
    ) -> String {
        FluelLocalization.string(
            key: english,
            defaultValue: english,
            japaneseFallback: japanese,
            bundle: .module,
            locale: locale
        )
    }
}
