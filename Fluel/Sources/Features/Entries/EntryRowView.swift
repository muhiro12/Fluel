//
//  EntryRowView.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import MHUI
import SwiftUI

struct EntryRowView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let entry: Entry

    var body: some View {
        HStack(alignment: .center, spacing: designMetrics.spacing.control) {
            EntryRowText(entry: entry)
                .frame(maxWidth: .infinity, alignment: .leading)

            timeTogetherText
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
        .mhRow()
    }

    private var timeTogetherText: some View {
        Text(entry.timeTogether().primaryText)
            .mhRowValue(colorRole: .accent)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    EntryRowView(entry: PreviewSampleData.sampleEntries[1])
        .mhTheme(.standard)
        .padding()
}
