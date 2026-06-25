//
//  ArchivedEntryEmptyState.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import MHUI
import SwiftUI

struct ArchivedEntryEmptyState: View {
    var body: some View {
        ContentUnavailableView {
            Label("Nothing is archived yet", systemImage: "archivebox")
        } description: {
            Text("Archived entries stay separate from what you still live with every day.")
        }
        .mhEmptyStateLayout()
    }
}
