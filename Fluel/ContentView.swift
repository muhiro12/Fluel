//
//  ContentView.swift
//  Fluel
//
//  Created by Hiromu Nakano on 2026/06/25.
//

import FluelLibrary
import MHUI
import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(
        filter: #Predicate<Preset> { preset in
            preset.isDefault
        }
    )
    private var defaultPresets: [Preset]

    @State private var activeSheet: ActiveEntrySheet?

    var body: some View {
        NavigationStack {
            ActiveEntryListView(addEntry: addEntry)
                .navigationTitle("Entries")
                .toolbar {
                    ContentToolbar(addEntry: addEntry)
                }
                .sheet(item: $activeSheet) { sheet in
                    EntryEditorView(draft: sheet.draft)
                }
        }
    }

    private func addEntry() {
        let draft = defaultPresets.first.map { preset in
            EntryOperations.makeDraft(from: preset.snapshot)
        } ?? EntryDraft()

        activeSheet = .init(draft: draft)
    }
}

#Preview {
    ContentView()
        .mhTheme(.standard)
        .modelContainer(PreviewSampleData.container())
}
