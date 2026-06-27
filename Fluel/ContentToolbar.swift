//
//  ContentToolbar.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import SwiftUI

struct ContentToolbar: ToolbarContent {
    let addEntry: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                NavigationLink(value: FluelRoute.dashboard) {
                    Label("Dashboard", systemImage: "rectangle.grid.2x2")
                }

                NavigationLink(value: FluelRoute.timeline) {
                    Label("Timeline", systemImage: "clock.arrow.circlepath")
                }

                NavigationLink(value: FluelRoute.milestones) {
                    Label("Milestones", systemImage: "flag")
                }

                NavigationLink(value: FluelRoute.presets) {
                    Label("Presets", systemImage: "bookmark")
                }

                NavigationLink(value: FluelRoute.archive) {
                    Label("Archive", systemImage: "archivebox")
                }
            } label: {
                Label("Browse", systemImage: "rectangle.grid.2x2")
            }
        }

        ToolbarItem(placement: .primaryAction) {
            Button(action: addEntry) {
                Label("Add Entry", systemImage: "plus")
            }
        }
    }
}
