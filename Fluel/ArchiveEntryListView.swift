//
//  ArchiveEntryListView.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import MHUI
import SwiftData
import SwiftUI

struct ArchiveEntryListView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(
        filter: #Predicate<Entry> { entry in
            entry.archivedAt != nil
        },
        sort: \Entry.archivedAt,
        order: .reverse
    )
    private var entries: [Entry]

    @State private var isShowingRestoreError = false

    var body: some View {
        Group {
            if entries.isEmpty {
                ArchivedEntryEmptyState()
            } else {
                List(entries) { entry in
                    NavigationLink {
                        EntryDetailView(entry: entry)
                    } label: {
                        EntryRowView(entry: entry)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            restore(entry)
                        } label: {
                            Label("Restore", systemImage: "arrow.uturn.backward")
                        }
                        .tint(.green)
                    }
                }
            }
        }
        .navigationTitle("Archive")
        .alert("Entry could not be restored", isPresented: $isShowingRestoreError) {
            Button("OK", role: .cancel) {
                isShowingRestoreError = false
            }
        }
    }

    private func restore(_ entry: Entry) {
        do {
            entry.restore()
            try modelContext.save()
        } catch {
            isShowingRestoreError = true
        }
    }
}

#Preview {
    NavigationStack {
        ArchiveEntryListView()
    }
    .mhTheme(.standard)
    .modelContainer(PreviewSampleData.container())
}
