//
//  PresetsEmptyState.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import MHUI
import SwiftUI

struct PresetsEmptyState: View {
    let create: () -> Void

    var body: some View {
        FluelEmptyState(
            "Presets",
            systemImage: "bookmark",
            description: "Reusable starting points will appear here."
        ) {
            Button("Create Preset", action: create)
                .buttonStyle(.mhPrimary)
        }
    }
}
