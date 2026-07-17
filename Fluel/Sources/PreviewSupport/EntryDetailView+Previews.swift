//
//  EntryDetailView+Previews.swift
//  Fluel
//
//  Created by Codex on 2026/07/17.
//

import MHUI
import SwiftData
import SwiftUI

#Preview("Entry detail - typical") {
    let preview = PreviewSampleData.detailContainer(title: "Notebook")

    NavigationStack {
        EntryDetailView(entry: preview.entry)
    }
    .mhTheme(.standard)
    .modelContainer(preview.container)
}

#Preview("Entry detail - photo") {
    let preview = PreviewSampleData.detailContainer(title: "Watch")

    NavigationStack {
        EntryDetailView(entry: preview.entry)
    }
    .mhTheme(.standard)
    .modelContainer(preview.container)
}

#Preview("Entry detail - archived") {
    let preview = PreviewSampleData.detailContainer(title: "Desk lamp")

    NavigationStack {
        EntryDetailView(entry: preview.entry)
    }
    .mhTheme(.standard)
    .modelContainer(preview.container)
}

#Preview("Entry detail - long text, large type") {
    let preview = PreviewSampleData.detailContainer(
        title: "Small wooden chair that moved through different rooms"
    )

    NavigationStack {
        EntryDetailView(entry: preview.entry)
    }
    .mhTheme(.standard)
    .modelContainer(preview.container)
    .dynamicTypeSize(.accessibility2)
}
