//
//  ActiveEntryListView.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import MHUI
import SwiftData
import SwiftUI

struct ActiveEntryListView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(
        filter: #Predicate<Entry> { entry in
            entry.archivedAt == nil
        },
        sort: \Entry.startDate,
        order: .forward
    )
    private var entries: [Entry]

    @State private var isShowingArchiveError = false
    @State private var searchText = ""
    @State private var sort = ActiveEntrySort.longestTogether
    @State private var filter = EntryListFilter.all

    let addEntry: () -> Void

    var body: some View {
        Group {
            if entries.isEmpty {
                ActiveEntryEmptyState(addEntry: addEntry)
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
                            archive(entry)
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }
                        .tint(.orange)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search entries")
        .toolbar {
            ToolbarItemGroup(placement: .secondaryAction) {
                Menu {
                    Picker("Sort", selection: $sort) {
                        ForEach(ActiveEntrySort.allCases) { sort in
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
        .alert("Entry could not be archived", isPresented: $isShowingArchiveError) {
            Button("OK", role: .cancel) {
                isShowingArchiveError = false
            }
        }
    }

    private var visibleEntries: [Entry] {
        let visibleIds = EntryOperations.activeEntries(
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

    private func archive(_ entry: Entry) {
        do {
            entry.archive()
            try modelContext.save()
        } catch {
            isShowingArchiveError = true
        }
    }

    private func clearSearchAndFilters() {
        searchText = ""
        filter = .all
    }
}
