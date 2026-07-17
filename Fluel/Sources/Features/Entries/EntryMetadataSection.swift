//
//  EntryMetadataSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import MHUI
import SwiftUI

struct EntryMetadataSection: View {
    let entry: Entry

    var body: some View {
        MHGroupedRows {
            LabeledContent(
                "Created",
                value: entry.createdAt.formatted(date: .abbreviated, time: .shortened)
            )
            .labeledContentStyle(.mhKeyValue)

            LabeledContent(
                "Updated",
                value: entry.updatedAt.formatted(date: .abbreviated, time: .shortened)
            )
            .labeledContentStyle(.mhKeyValue)

            if let archivedAt = entry.archivedAt {
                LabeledContent(
                    "Archived",
                    value: archivedAt.formatted(date: .abbreviated, time: .shortened)
                )
                .labeledContentStyle(.mhKeyValue)
            }
        }
        .mhSection(
            "Entry",
            supporting: "Dates that describe this record in Fluel."
        )
    }
}
