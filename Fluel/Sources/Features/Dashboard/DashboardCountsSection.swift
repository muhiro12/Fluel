//
//  DashboardCountsSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import MHUI
import SwiftUI

struct DashboardCountsSection: View {
    let summary: EntryDashboardSummary

    var body: some View {
        Section {
            LabeledContent("Total", value: summary.totalCount.formatted())
            LabeledContent("Active", value: summary.activeCount.formatted())
            LabeledContent("Archived", value: summary.archivedCount.formatted())
            LabeledContent("With note", value: summary.noteCount.formatted())
            LabeledContent("With photo", value: summary.photoCount.formatted())
        } header: {
            FluelSectionHeader("The quiet overview")
        }
        .labeledContentStyle(.mhKeyValue)
    }
}
