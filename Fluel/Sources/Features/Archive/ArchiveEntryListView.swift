//
//  ArchiveEntryListView.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
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
    @State private var searchText = ""
    @State private var sort = ArchivedEntrySort.recentlyArchived
    @State private var filter = EntryListFilter.all

    var body: some View {
        Group {
            if entries.isEmpty {
                ArchivedEntryEmptyState()
            } else if visibleEntries.isEmpty {
                EntryListFilteredEmptyState(clear: clearSearchAndFilters)
            } else {
                List(visibleEntries) { entry in
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
        .searchable(text: $searchText, prompt: "Search archive")
        .toolbar {
            ToolbarItemGroup(placement: .secondaryAction) {
                Menu {
                    Picker("Sort", selection: $sort) {
                        ForEach(ArchivedEntrySort.allCases) { sort in
                            Text(sort.label)
                                .tag(sort)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }

                Menu {
                    Picker("Filter", selection: $filter) {
                        ForEach(EntryListFilter.allCases) { filter in
                            Text(filter.label)
                                .tag(filter)
                        }
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .alert("Entry could not be restored", isPresented: $isShowingRestoreError) {
            Button("OK", role: .cancel) {
                isShowingRestoreError = false
            }
        }
    }

    private var visibleEntries: [Entry] {
        let visibleIds = EntryOperations.archivedEntries(
            from: entries.map(\.snapshot),
            searchText: searchText,
            filter: filter,
            sort: sort
        )
        .map(\.id)

        return visibleIds.compactMap { id in
            entries.first { entry in
                entry.id == id
            }
        }
    }

    private func restore(_ entry: Entry) {
        do {
            try modelContext.performAndSave {
                entry.restore()
            }
        } catch {
            isShowingRestoreError = true
        }
    }

    private func clearSearchAndFilters() {
        searchText = ""
        filter = .all
    }
}

#Preview("Archive - empty") {
    NavigationStack {
        ArchiveEntryListView()
    }
    .mhTheme(.standard)
    .modelContainer(PreviewSampleData.emptyContainer())
}

#Preview("Archive - archived entries") {
    NavigationStack {
        ArchiveEntryListView()
    }
    .mhTheme(.standard)
    .modelContainer(PreviewSampleData.archiveContainer())
}
