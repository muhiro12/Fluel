//
//  TimelineEmptyState.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import SwiftUI

struct TimelineEmptyState: View {
    var body: some View {
        FluelEmptyState(
            "Timeline",
            systemImage: "clock.arrow.circlepath",
            description: "Activity will gather as entries are added, adjusted, and archived."
        )
    }
}
