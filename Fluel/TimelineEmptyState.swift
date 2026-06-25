//
//  TimelineEmptyState.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import MHUI
import SwiftUI

struct TimelineEmptyState: View {
    var body: some View {
        ContentUnavailableView {
            Label("Timeline", systemImage: "clock.arrow.circlepath")
        } description: {
            Text("Activity will gather as entries are added, adjusted, and archived.")
        }
        .mhEmptyStateLayout()
    }
}
