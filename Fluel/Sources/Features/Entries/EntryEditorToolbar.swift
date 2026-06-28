//
//  EntryEditorToolbar.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import SwiftUI

struct EntryEditorToolbar: ToolbarContent {
    let canSave: Bool
    let cancel: () -> Void
    let save: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", action: cancel)
        }

        ToolbarItem(placement: .confirmationAction) {
            Button("Save", action: save)
                .disabled(!canSave)
        }
    }
}
