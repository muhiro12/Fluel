//
//  TimelineSummarySection.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import MHUI
import SwiftUI

struct TimelineSummarySection: View {
    let summary: EntryTimelineSummary

    var body: some View {
        Section("Timeline summary") {
            LabeledContent("Visible", value: summary.visibleActivityCount.formatted())
            LabeledContent("Total", value: summary.totalActivityCount.formatted())
            LabeledContent("Months", value: summary.representedMonthCount.formatted())
            LabeledContent("Added", value: summary.addedCount.formatted())
            LabeledContent("Updated", value: summary.updatedCount.formatted())
            LabeledContent("Archived", value: summary.archivedCount.formatted())
        }
        .labeledContentStyle(.mhKeyValue)
    }
}
