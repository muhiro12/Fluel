//
//  DashboardMilestonesSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import MHUI
import SwiftUI

struct DashboardMilestonesSection: View {
    let milestones: [EntryMilestone]

    var body: some View {
        Section {
            ForEach(milestones) { milestone in
                MilestoneRowView(
                    milestone: milestone,
                    approximateLabel: Text("Approximate milestone")
                )
            }
        } header: {
            FluelSectionHeader("Upcoming milestones")
        }
    }
}
