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
        ContentUnavailableView {
            Label("Presets", systemImage: "bookmark")
        } description: {
            Text("Reusable starting points will appear here.")
        } actions: {
            Button("Create Preset", action: create)
                .buttonStyle(.mhPrimary)
        }
        .mhEmptyStateLayout()
    }
}
