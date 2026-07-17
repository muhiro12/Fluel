//
//  EntryArchiveSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import MHUI
import SwiftUI

struct EntryArchiveSection: View {
    let entry: Entry
    let archive: () -> Void
    let restore: () -> Void
    let deletePermanently: () -> Void

    var body: some View {
        Section {
            if entry.isArchived {
                LabeledContent {
                    Text("Moved out of daily life")
                } label: {
                    Text("State")
                }
            } else {
                LabeledContent {
                    Text("Still with you")
                        .mhBadge(
                            style: .accent,
                            accessibilityLabel: Text("Still with you")
                        )
                } label: {
                    Text("State")
                }
            }

            EntryArchiveActions(
                isArchived: entry.isArchived,
                archive: archive,
                restore: restore,
                deletePermanently: deletePermanently
            )
        } header: {
            MHSectionHeader("Archive")
        }
        .labeledContentStyle(.mhKeyValue)
    }
}
