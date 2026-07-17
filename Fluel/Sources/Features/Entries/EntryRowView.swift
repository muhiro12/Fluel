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
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    let entry: Entry

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(
                alignment: .leading,
                spacing: designMetrics.spacing.control
            ))
            : AnyLayout(HStackLayout(
                alignment: .center,
                spacing: designMetrics.spacing.control
            ))

        layout {
            EntryRowText(entry: entry)
                .frame(maxWidth: .infinity, alignment: .leading)

            timeTogetherLabel
                .frame(
                    maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : nil,
                    alignment: dynamicTypeSize.isAccessibilitySize ? .leading : .trailing
                )
                .multilineTextAlignment(
                    dynamicTypeSize.isAccessibilitySize ? .leading : .trailing
                )
        }
        .accessibilityElement(children: .combine)
    }

    private var timeTogetherLabel: some View {
        FluelTimeTogetherLabel(text: entry.timeTogether().primaryText)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    EntryRowView(entry: PreviewSampleData.sampleEntries[1])
        .mhRow()
        .mhTheme(.standard)
        .padding()
}
