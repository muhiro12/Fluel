//
//  EntryListFilteredEmptyState.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import MHUI
import SwiftUI

struct EntryListFilteredEmptyState: View {
    let clear: () -> Void

    var body: some View {
        FluelEmptyState(
            "No entries found",
            systemImage: "magnifyingglass",
            description: "Try a different search or filter."
        ) {
            Button("Clear Search and Filters", action: clear)
                .buttonStyle(.mhPrimary)
        }
    }
}
