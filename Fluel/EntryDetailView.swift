//
//  EntryDetailView.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import MHUI
import SwiftUI

struct EntryDetailView: View {
    let entry: Entry

    var body: some View {
        List {
            EntryDetailHeader(entry: entry)

            EntryStartDetailSection(entry: entry)

            EntryTimeTogetherSection(entry: entry)

            EntryMetadataSection(entry: entry)
        }
        .navigationTitle(entry.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        EntryDetailView(entry: PreviewSampleData.sampleEntries[1])
    }
    .mhTheme(.standard)
}
