//
//  ContentToolbar.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import SwiftUI

struct ContentToolbar: ToolbarContent {
    @Binding var activeSheet: ActiveEntrySheet?

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            NavigationLink {
                DashboardView()
            } label: {
                Label("Dashboard", systemImage: "rectangle.grid.2x2")
            }

            NavigationLink {
                TimelineView()
            } label: {
                Label("Timeline", systemImage: "clock.arrow.circlepath")
            }

            NavigationLink {
                MilestonesView()
            } label: {
                Label("Milestones", systemImage: "flag")
            }

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
}
