//
//  ContentDetailView.swift
//  Fluel
//
//  Created by Codex on 2026/07/16.
//

import SwiftUI

struct ContentDetailView: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    let route: FluelRoute
    let addEntry: () -> Void

    var body: some View {
        switch route {
        case .entries:
            NavigationStack {
                ActiveEntryListView(addEntry: addEntry)
                    .navigationTitle(route.title)
                    .navigationBarTitleDisplayMode(titleDisplayMode)
                    .toolbar {
                        ContentToolbar(addEntry: addEntry)
                    }
            }
        case .dashboard:
            NavigationStack {
                DashboardView()
                    .navigationBarTitleDisplayMode(titleDisplayMode)
            }
        case .timeline:
            NavigationStack {
                TimelineView()
                    .navigationBarTitleDisplayMode(titleDisplayMode)
            }
        case .milestones:
            NavigationStack {
                MilestonesView()
                    .navigationBarTitleDisplayMode(titleDisplayMode)
            }
        case .presets:
            NavigationStack {
                PresetsView()
                    .navigationBarTitleDisplayMode(titleDisplayMode)
            }
        case .archive:
            NavigationStack {
                ArchiveEntryListView()
                    .navigationBarTitleDisplayMode(titleDisplayMode)
            }
        }
    }

    private var titleDisplayMode: NavigationBarItem.TitleDisplayMode {
        horizontalSizeClass == .compact ? .inline : .large
    }
}
