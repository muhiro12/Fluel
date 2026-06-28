//
//  ContentView.swift
//  Fluel
//
//  Created by Hiromu Nakano on 2026/06/25.
//

import FluelLibrary
import MHPlatform
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

    @Environment(FluelRouteInbox.self)
    private var routeInbox
    @Environment(FluelRoutePipeline.self)
    private var routePipeline

    @State private var navigationPath = [FluelRoute]()
    @State private var activeSheet: ActiveEntrySheet?

    private var invalidDeepLinkAlertBinding: Binding<Bool> {
        .init(
            get: {
                routePipeline.lastParseFailureURL != nil
            },
            set: { isPresented in
                if !isPresented {
                    routePipeline.clearLastParseFailure()
                }
            }
        )
    }

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
                .alert(
                    "Unsupported Link",
                    isPresented: invalidDeepLinkAlertBinding,
                    presenting: routePipeline.lastParseFailureURL
                ) { _ in
                    Button("OK", role: .cancel) {
                        routePipeline.clearLastParseFailure()
                    }
                } message: { _ in
                    Text("This link is not supported by this version of Fluel.")
                }
                .mhRouteHandler(routeInbox) { link in
                    openSupportedLink(link)
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

    private func openSupportedLink(_ link: FluelLink) {
        switch link {
        case .destination(let destination):
            openDestination(destination)
        }
    }

    private func openDestination(_ destination: FluelLinkDestination) {
        switch destination {
        case .entries:
            navigationPath = []
        case .dashboard:
            navigationPath = [.dashboard]
        case .timeline:
            navigationPath = [.timeline]
        case .milestones:
            navigationPath = [.milestones]
        case .presets:
            navigationPath = [.presets]
        case .archive:
            navigationPath = [.archive]
        }
    }
}

#Preview("Active entries - empty") {
    FluelPreviewContainer(.empty) {
        ContentView()
    }
}

#Preview("Active entries - typical") {
    FluelPreviewContainer {
        ContentView()
    }
}

#Preview("Active entries - dense, large type") {
    FluelPreviewContainer(.dense) {
        ContentView()
    }
    .dynamicTypeSize(.accessibility2)
}

#Preview("Active entries - dark") {
    FluelPreviewContainer {
        ContentView()
    }
    .preferredColorScheme(.dark)
}
