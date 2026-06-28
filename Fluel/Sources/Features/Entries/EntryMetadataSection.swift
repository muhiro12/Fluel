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
        Section {
            LabeledContent(
                "Created",
                value: entry.createdAt.formatted(date: .abbreviated, time: .shortened)
            )
            LabeledContent(
                "Updated",
                value: entry.updatedAt.formatted(date: .abbreviated, time: .shortened)
            )

            if let archivedAt = entry.archivedAt {
                LabeledContent(
                    "Archived",
                    value: archivedAt.formatted(date: .abbreviated, time: .shortened)
                )
            }
        } header: {
            FluelSectionHeader("Entry")
        }
        .labeledContentStyle(.mhKeyValue)
    }
}
