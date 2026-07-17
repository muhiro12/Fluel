//
//  PresetEditorView+Previews.swift
//  Fluel
//
//  Created by Codex on 2026/07/17.
//

import MHUI
import SwiftData
import SwiftUI

#Preview("Create preset - empty") {
    PresetEditorView(preset: nil)
        .modelContainer(PreviewSampleData.emptyContainer())
        .mhTheme(.standard)
}

#Preview("Edit preset - filled") {
    let preview = PreviewSampleData.presetEditorContainer(title: "Furniture")

    PresetEditorView(preset: preview.preset)
        .modelContainer(preview.container)
        .mhTheme(.standard)
}
