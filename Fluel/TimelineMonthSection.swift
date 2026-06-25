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
    private enum Layout {
        static let verticalSpacing: CGFloat = 4
    }

    let month: EntryTimelineMonth

    var body: some View {
        Section(month.monthDate.formatted(.dateTime.month(.wide).year())) {
            LabeledContent("Monthly trends", value: trendsText)
                .labeledContentStyle(.mhKeyValue)

            ForEach(month.activity) { item in
                VStack(alignment: .leading, spacing: Layout.verticalSpacing) {
                    Text(item.kind.label)
                        .mhRowOverline()

                    Text(item.title)
                        .mhRowTitle()

                    Text(item.date.formatted(date: .abbreviated, time: .omitted))
                        .mhRowSupporting()
                }
            }
        }
    }

    private var trendsText: String {
        let parts = [
            trendText(count: month.addedCount, label: "added"),
            trendText(count: month.updatedCount, label: "updated"),
            trendText(count: month.archivedCount, label: "archived")
        ]
        .compactMap(\.self)

        return parts.joined(separator: ", ")
    }

    private func trendText(count: Int, label: String) -> String? {
        guard count > 0 else {
            return nil
        }

        return "\(count.formatted()) \(label)"
    }
}
