//
//  PreviewRootView.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import SwiftData
import SwiftUI

struct PreviewRootView: View {
    @Query(sort: \Entry.updatedAt, order: .reverse)
    private var entries: [Entry]

    let screen: PreviewSampleData.Screen

    var body: some View {
        switch screen {
        case .activeEntries:
            ContentView()
        case .dashboard:
            NavigationStack {
                DashboardView()
            }
        case .timeline:
            NavigationStack {
                TimelineView()
            }
        case .milestones:
            NavigationStack {
                MilestonesView()
            }
        case .presets:
            NavigationStack {
                PresetsView()
            }
        case .archive:
            NavigationStack {
                ArchiveEntryListView()
            }
        case .entryDetail:
            detailView(entry: activeDetailEntry)
        case .archivedEntryDetail:
            detailView(entry: archivedDetailEntry)
        case .entryEditor:
            EntryEditorView(draft: PreviewSampleData.longTextDraft)
        }
    }

    private var activeDetailEntry: Entry? {
        entries.first { entry in
            entry.title == "Notebook"
        } ?? entries.first { entry in
            !entry.isArchived
        }
    }

    private var archivedDetailEntry: Entry? {
        entries.first(where: \.isArchived)
    }

    @ViewBuilder
    private func detailView(entry: Entry?) -> some View {
        if let entry {
            NavigationStack {
                EntryDetailView(entry: entry)
            }
        } else {
            ContentUnavailableView {
                Label("Preview entry is unavailable", systemImage: "exclamationmark.triangle")
            } description: {
                Text("Launch this preview screen with a sample-data scenario that contains entries.")
            }
        }
    }
}
