//
//  EntryArchiveActions.swift
//  Fluel
//
//  Created by Codex on 2026/07/17.
//

import MHUI
import SwiftUI

struct EntryArchiveActions: View {
    let isArchived: Bool
    let archive: () -> Void
    let restore: () -> Void
    let deletePermanently: () -> Void

    var body: some View {
        if isArchived {
            MHActionGroup {
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
                .buttonStyle(.mhDestructive)
            }
        } else {
            MHActionGroup {
                Button {
                    archive()
                } label: {
                    Label("Archive Entry", systemImage: "archivebox")
                }
            }
        }
    }
}
