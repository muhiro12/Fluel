//
//  EntryEditorView+Previews.swift
//  Fluel
//
//  Created by Codex on 2026/07/17.
//

import MHUI
import SwiftData
import SwiftUI

#Preview("Add entry - empty") {
    EntryEditorView()
        .modelContainer(PreviewSampleData.emptyContainer())
        .mhTheme(.standard)
}

#Preview("Edit entry - filled") {
    let preview = PreviewSampleData.detailContainer(
        id: SampleDataManifest.Identifier.watch
    )

    EntryEditorView(
        editing: preview.entry,
        draft: PreviewSampleData.draft(for: preview.entry),
        photoData: preview.entry.photoData
    )
    .modelContainer(preview.container)
    .mhTheme(.standard)
}

#Preview("Create entry - long text, dark") {
    EntryEditorView(draft: PreviewSampleData.longTextDraft)
        .modelContainer(PreviewSampleData.emptyContainer())
        .mhTheme(.standard)
        .preferredColorScheme(.dark)
}
