//
//  DashboardEntryHighlightsSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import MHUI
import SwiftUI

struct DashboardEntryHighlightsSection: View {
    let activeEntry: EntrySnapshot?
    let archivedEntry: EntrySnapshot?

    var body: some View {
        if hasHighlights {
            DashboardHighlightsLayout(
                activeEntry: activeEntry,
                archivedEntry: archivedEntry
            )
            .mhSection(
                "Highlights",
                supporting: "The moments that define the collection right now."
            )
        }
    }

    private var hasHighlights: Bool {
        activeEntry != nil || archivedEntry?.archivedAt != nil
    }
}
