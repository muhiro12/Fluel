//
//  DashboardHighlightsLayout.swift
//  Fluel
//
//  Created by Codex on 2026/07/23.
//

import FluelLibrary
import MHUI
import SwiftUI

struct DashboardHighlightsLayout: View {
    let activeEntry: EntrySnapshot?
    let archivedEntry: EntrySnapshot?

    var body: some View {
        if let activeEntry,
           let archivedEntry,
           let archivedAt = archivedEntry.archivedAt {
            MHFeatureGrid {
                DashboardHighlightFeature.longestTogether(activeEntry)
            } supporting: {
                DashboardHighlightFeature.recentlyArchived(
                    archivedEntry,
                    at: archivedAt
                )
            }
        } else if let activeEntry {
            DashboardHighlightFeature.longestTogether(activeEntry)
        } else if let archivedEntry,
                  let archivedAt = archivedEntry.archivedAt {
            DashboardHighlightFeature.recentlyArchived(
                archivedEntry,
                at: archivedAt
            )
        }
    }
}
