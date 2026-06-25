//
//  ContentView.swift
//  Fluel
//
//  Created by Hiromu Nakano on 2026/06/25.
//

import MHUI
import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var activeSheet: ActiveEntrySheet?

    var body: some View {
        NavigationStack {
            ActiveEntryListView {
                activeSheet = .newEntry
            }
            .navigationTitle("Entries")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        ArchiveEntryListView()
                    } label: {
                        Label("Archive", systemImage: "archivebox")
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        activeSheet = .newEntry
                    } label: {
                        Label("Add Entry", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .newEntry:
                    EntryEditorView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .mhTheme(.standard)
        .modelContainer(PreviewSampleData.container())
}
