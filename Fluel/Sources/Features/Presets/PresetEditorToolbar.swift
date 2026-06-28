//
//  PresetEditorToolbar.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import SwiftUI

struct PresetEditorToolbar: ToolbarContent {
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
