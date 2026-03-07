//
//  ItemDetailView.swift
//  Fluel
//
//  Created by OpenAI on 2026/03/07.
//

import SwiftUI

struct ItemDetailView: View {
    let item: Item

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let elapsed = ElapsedTimeSnapshot(
                startDate: item.startDate,
                referenceDate: context.date
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(item.name)
                            .font(.largeTitle.weight(.medium))

                        Text(item.startDate, format: .dateTime.year().month().day())
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(elapsed.dayHeadline)
                            .font(.system(size: 64, weight: .semibold, design: .rounded))
                            .monospacedDigit()

                        Text("いっしょに過ごした日数")
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 20) {
                        DetailMetric(
                            title: "年・月・日で見ると",
                            value: elapsed.fullBreakdown
                        )
                        DetailMetric(
                            title: "積もった月数",
                            value: elapsed.monthSummary
                        )
                        DetailMetric(
                            title: "次の節目",
                            value: elapsed.nextAnniversarySummary
                        )
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        Color(uiColor: .secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct DetailMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3.weight(.medium))
                .monospacedDigit()
        }
    }
}

#Preview {
    ItemDetailView(item: Item(name: "財布", startDate: .now))
}
