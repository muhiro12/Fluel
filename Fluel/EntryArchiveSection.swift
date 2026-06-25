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
        Section("Archive") {
            if entry.isArchived {
                LabeledContent("State", value: "Moved out of daily life")

                Button {
                    restore()
                } label: {
                    Label("Restore Entry", systemImage: "arrow.uturn.backward")
                }

                Button(role: .destructive) {
                    deletePermanently()
                } label: {
                    Label("Delete Permanently", systemImage: "trash")
                }
            } else {
                LabeledContent("State", value: "Still with you")

                Button {
                    archive()
                } label: {
                    Label("Archive Entry", systemImage: "archivebox")
                }
            }
        }
    }
}
