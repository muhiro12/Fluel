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
    @Environment(\.calendar)
    private var calendar

    @Environment(\.modelContext)
    private var modelContext

    @Query private var entries: [Entry]

    @Query private var activity: [EntryActivity]

    @State private var isShowingArchiveError = false
    @State private var isShowingSampleDataError = false
    @State private var isConfirmingSampleDataRemoval = false
    @State private var searchText = ""
    @State private var sort = ActiveEntrySort.longestTogether
    @State private var filter = EntryListFilter.all

    let addEntry: () -> Void

    var body: some View {
        List {
            if !activeEntries.isEmpty,
               !visibleEntries.isEmpty {
                ForEach(visibleEntries) { entry in
                    NavigationLink {
                        EntryDetailView(entry: entry)
                    } label: {
                        EntryRowView(entry: entry)
                    }
                    .mhRow()
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            archive(entry)
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }
                        .tint(Color.accentColor)
                    }
                }
            }
        }
        .mhListChrome()
        .overlay {
            if activeEntries.isEmpty {
                ActiveEntryEmptyState(
                    addEntry: addEntry,
                    addSampleData: addSampleDataAction
                )
            } else if visibleEntries.isEmpty {
                EntryListFilteredEmptyState(clear: clearSearchAndFilters)
            }
        }
        .searchable(text: $searchText, prompt: "Search entries")
        .toolbar {
            secondaryToolbar
        }
        .confirmationDialog(
            "Remove sample data?",
            isPresented: $isConfirmingSampleDataRemoval,
            titleVisibility: .visible
        ) {
            Button("Remove Sample Data", role: .destructive) {
                removeSampleData()
            }

            Button("Cancel", role: .cancel) {
                isConfirmingSampleDataRemoval = false
            }
        } message: {
            Text(
                "Sample entries, all of their activity, and any changes you made to them will be deleted."
            )
        }
        .alert("Entry could not be archived", isPresented: $isShowingArchiveError) {
            Button("OK", role: .cancel) {
                isShowingArchiveError = false
            }
        }
        .alert("Sample data could not be updated", isPresented: $isShowingSampleDataError) {
            Button("OK", role: .cancel) {
                isShowingSampleDataError = false
            }
        }
    }

    @ToolbarContentBuilder private var secondaryToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .secondaryAction) {
            sortMenu
            filterMenu
            sampleDataMenu
        }
    }

    private var sortMenu: some View {
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
    }

    private var filterMenu: some View {
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

    private var sampleDataMenu: some View {
        Menu {
            Button {
                installSampleData()
            } label: {
                Label("Add Sample Data", systemImage: "plus")
            }
            .disabled(!canInstallSampleData)

            Button(role: .destructive) {
                isConfirmingSampleDataRemoval = true
            } label: {
                Label("Remove Sample Data", systemImage: "trash")
            }
            .disabled(installedSampleEntryCount == 0)
        } label: {
            Label("Sample Data", systemImage: "shippingbox")
        }
    }

    private var activeEntries: [Entry] {
        entries.filter { entry in
            !entry.isArchived
        }
    }

    private var installedSampleEntryCount: Int {
        SampleDataStore.installedEntryCount(in: entries)
    }

    private var canInstallSampleData: Bool {
        installedSampleEntryCount < SampleDataManifest.entryCount
    }

    private var addSampleDataAction: (() -> Void)? {
        guard canInstallSampleData else {
            return nil
        }

        return installSampleData
    }

    private var visibleEntries: [Entry] {
        let visibleIds = EntryOperations.activeEntries(
            from: activeEntries.map(\.snapshot),
            searchText: searchText,
            filter: filter,
            sort: sort
        )
        .map(\.id)

        return visibleIds.compactMap { id in
            activeEntries.first { entry in
                entry.id == id
            }
        }
    }

    private func archive(_ entry: Entry) {
        do {
            try EntryStore.archive(
                entry,
                archivedAt: .now,
                in: modelContext
            )
        } catch {
            isShowingArchiveError = true
        }
    }

    private func installSampleData() {
        do {
            try SampleDataStore.install(
                existingEntries: entries,
                existingActivity: activity,
                referenceDate: .now,
                calendar: calendar,
                in: modelContext
            )
        } catch {
            isShowingSampleDataError = true
        }
    }

    private func removeSampleData() {
        do {
            try SampleDataStore.remove(
                existingEntries: entries,
                existingActivity: activity,
                in: modelContext
            )
        } catch {
            isShowingSampleDataError = true
        }
    }

    private func clearSearchAndFilters() {
        searchText = ""
        filter = .all
    }
}
