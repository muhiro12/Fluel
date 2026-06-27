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

    @State private var intentRouter = FluelIntentRouter.shared
    @State private var navigationPath = [FluelRoute]()
    @State private var activeSheet: ActiveEntrySheet?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ActiveEntryListView(addEntry: addEntry)
                .navigationTitle("Entries")
                .toolbar {
                    ContentToolbar(addEntry: addEntry)
                }
                .navigationDestination(for: FluelRoute.self) { route in
                    routeView(for: route)
                }
                .sheet(item: $activeSheet) { sheet in
                    EntryEditorView(draft: sheet.draft)
                }
                .onAppear(perform: consumeIntentDestination)
                .onChange(of: intentRouter.destination) {
                    consumeIntentDestination()
                }
        }
    }

    private func addEntry() {
        let draft = defaultPresets.first.map { preset in
            EntryOperations.makeDraft(from: preset.snapshot)
        } ?? EntryDraft()

        activeSheet = .init(draft: draft)
    }

    @ViewBuilder
    private func routeView(for route: FluelRoute) -> some View {
        switch route {
        case .dashboard:
            DashboardView()
        case .timeline:
            TimelineView()
        case .milestones:
            MilestonesView()
        case .presets:
            PresetsView()
        case .archive:
            ArchiveEntryListView()
        }
    }

    private func consumeIntentDestination() {
        guard let destination = intentRouter.consumeDestination() else {
            return
        }

        if let route = destination.route {
            navigationPath = [route]
        } else {
            navigationPath = []
        }
    }
}

#Preview("Active entries - empty") {
    ContentView()
        .mhTheme(.standard)
        .modelContainer(PreviewSampleData.emptyContainer())
}

#Preview("Active entries - typical") {
    ContentView()
        .mhTheme(.standard)
        .modelContainer(PreviewSampleData.container())
}

#Preview("Active entries - dense, large type") {
    ContentView()
        .mhTheme(.standard)
        .modelContainer(PreviewSampleData.denseContainer())
        .dynamicTypeSize(.accessibility2)
}

#Preview("Active entries - dark") {
    ContentView()
        .mhTheme(.standard)
        .modelContainer(PreviewSampleData.container())
        .preferredColorScheme(.dark)
}
