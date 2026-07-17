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
    let preview = PreviewSampleData.detailContainer(
        id: SampleDataManifest.Identifier.notebook
    )

    NavigationStack {
        EntryDetailView(entry: preview.entry)
    }
    .mhTheme(.standard)
    .modelContainer(preview.container)
}

#Preview("Entry detail - photo") {
    let preview = PreviewSampleData.detailContainer(
        id: SampleDataManifest.Identifier.watch
    )

    NavigationStack {
        EntryDetailView(entry: preview.entry)
    }
    .mhTheme(.standard)
    .modelContainer(preview.container)
}

#Preview("Entry detail - archived") {
    let preview = PreviewSampleData.detailContainer(
        id: SampleDataManifest.Identifier.deskLamp
    )

    NavigationStack {
        EntryDetailView(entry: preview.entry)
    }
    .mhTheme(.standard)
    .modelContainer(preview.container)
}

#Preview("Entry detail - long text, large type") {
    let preview = PreviewSampleData.detailContainer(
        id: PreviewSampleData.uuid(PreviewSampleData.Identifier.longTitle)
    )

    NavigationStack {
        EntryDetailView(entry: preview.entry)
    }
    .mhTheme(.standard)
    .modelContainer(preview.container)
    .dynamicTypeSize(.accessibility2)
}
