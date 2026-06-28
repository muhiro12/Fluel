//
//  EntryStartDetailSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import MHUI
import SwiftUI

struct EntryStartDetailSection: View {
    let entry: Entry

    var body: some View {
        Section {
            LabeledContent("Start", value: entry.startPrecision.startLabel(for: entry.startDate))
            LabeledContent("Precision", value: entry.startPrecision.knownAsText)

            if let rangeLabel = entry.startPrecision.startRangeLabel(for: entry.startDate) {
                LabeledContent("Start range", value: rangeLabel)
            }
        } header: {
            FluelSectionHeader("Start")
        }
        .labeledContentStyle(.mhKeyValue)
    }
}
