//
//  ArchivedEntryEmptyState.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import SwiftUI

struct ArchivedEntryEmptyState: View {
    var body: some View {
        FluelEmptyState(
            "Nothing is archived yet",
            systemImage: "archivebox",
            description: "Archived entries stay separate from what you still live with every day."
        )
    }
}
