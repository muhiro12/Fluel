//
//  MilestonesEmptyState.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import MHUI
import SwiftUI

struct MilestonesEmptyState: View {
    var body: some View {
        ContentUnavailableView {
            Label("No upcoming milestones", systemImage: "flag")
        } description: {
            Text("Milestones appear for active entries as yearly dates come closer.")
        }
        .mhEmptyStateLayout()
    }
}
