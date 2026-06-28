//
//  ActiveEntryEmptyState.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import MHUI
import SwiftUI

struct ActiveEntryEmptyState: View {
    let addEntry: () -> Void

    var body: some View {
        FluelEmptyState(
            "Begin with one entry",
            systemImage: "clock",
            description: "Add one thing or place you live with and keep the start as precisely as you know it."
        ) {
            Button("Add Entry", action: addEntry)
                .buttonStyle(.mhPrimary)
        }
    }
}
