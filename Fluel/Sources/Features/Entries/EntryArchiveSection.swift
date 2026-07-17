//
//  EntryArchiveSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import MHUI
import SwiftUI

struct EntryArchiveSection: View {
    @Environment(\.mhTheme)
    private var theme

    let entry: Entry
    let archive: () -> Void
    let restore: () -> Void
    let deletePermanently: () -> Void

    var body: some View {
        let supporting = entry.isArchived
            ? Text("Restore this entry or remove it permanently.")
            : Text("Move this entry out of daily life without losing its history.")

        VStack(alignment: .leading, spacing: theme.spacing.control) {
            MHGroupedRows {
                if entry.isArchived {
                    LabeledContent {
                        Text("Moved out of daily life")
                    } label: {
                        Text("State")
                    }
                    .labeledContentStyle(.mhKeyValue)
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
                    .labeledContentStyle(.mhKeyValue)
                }
            }

            EntryArchiveActions(
                isArchived: entry.isArchived,
                archive: archive,
                restore: restore,
                deletePermanently: deletePermanently
            )
        }
        .mhSection(
            title: Text("Archive"),
            supporting: supporting
        )
    }
}
