//
//  MilestonesEmptyState.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import SwiftUI

struct MilestonesEmptyState: View {
    var body: some View {
        FluelEmptyState(
            "No upcoming milestones",
            systemImage: "flag",
            description: "Milestones appear for active entries as yearly dates come closer."
        )
    }
}
