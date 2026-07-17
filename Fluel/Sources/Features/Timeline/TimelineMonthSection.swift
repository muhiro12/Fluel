//
//  TimelineMonthSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import MHUI
import SwiftUI

struct TimelineMonthSection: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let month: EntryTimelineMonth

    var body: some View {
        Section {
            LabeledContent("Monthly trends", value: trendsText)
                .labeledContentStyle(.mhKeyValue)

            ForEach(month.activity) { item in
                VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                    Text(item.kind.label)
                        .mhTextStyle(.metadata, colorRole: .secondaryText)

                    Text(item.title)
                        .mhRowTitle()

                    Text(item.date.formatted(date: .abbreviated, time: .omitted))
                        .mhRowSupporting()
                }
                .mhRow()
            }
        } header: {
            MHSectionHeader(
                title: Text(month.monthDate.formatted(.dateTime.month(.wide).year()))
            )
        }
    }

    private var trendsText: String {
        let parts = [
            trendText(count: month.addedCount, label: String(localized: "added")),
            trendText(count: month.updatedCount, label: String(localized: "updated")),
            trendText(count: month.archivedCount, label: String(localized: "archived"))
        ]
        .compactMap(\.self)

        return parts.formatted(.list(type: .and, width: .narrow))
    }

    private func trendText(count: Int, label: String) -> String? {
        guard count > 0 else {
            return nil
        }

        return "\(count.formatted()) \(label)"
    }
}
