//
//  ContentView.swift
//  Fluel
//
//  Created by Hiromu Nakano on 2026/06/25.
//

import FluelLibrary
import Foundation
import MHPlatform
import MHUI
import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(sort: \Preset.title, order: .forward)
    private var presets: [Preset]

    @Query(sort: \PresetDefaultSelection.selectedAt, order: .reverse)
    private var defaultSelections: [PresetDefaultSelection]

    @Environment(FluelRouteInbox.self)
    private var routeInbox
    @Environment(FluelRoutePipeline.self)
    private var routePipeline

    @State private var selectedRoute: FluelRoute? = .entries
    @State private var preferredCompactColumn = NavigationSplitViewColumn.detail
    @State private var detailIdentity = UUID()
    @State private var activeSheet: ActiveEntrySheet?

    private var invalidDeepLinkBinding: Binding<URL?> {
        .init(
            get: {
                routePipeline.lastParseFailureURL
            },
            set: { invalidURL in
                if invalidURL == nil {
                    routePipeline.clearLastParseFailure()
                }
            }
        )
    }

    var body: some View {
        NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
            ContentSidebar(selection: $selectedRoute)
        } detail: {
            ContentDetailView(
                route: selectedRoute ?? .entries,
                addEntry: addEntry
            )
            .id(detailIdentity)
        }
        .sheet(item: $activeSheet) { sheet in
            EntryEditorView(draft: sheet.draft)
        }
        .alert("Unsupported Link", item: invalidDeepLinkBinding) { _ in
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

    private func addEntry() {
        let defaultPresetID = PresetStore.selectedDefaultPresetID(from: defaultSelections)
        let defaultPreset = defaultPresetID.flatMap { presetID in
            PresetStore.preset(withID: presetID, in: presets)
        }
        let draft = defaultPreset.flatMap { preset in
            try? EntryOperations.makeDraft(from: preset.snapshot(isDefault: true))
        } ?? EntryDraft()

        activeSheet = .init(draft: draft)
    }

    private func openSupportedLink(_ link: FluelLink) {
        switch link {
        case .destination(let destination):
            openDestination(destination)
        }
    }

    private func openDestination(_ destination: FluelLinkDestination) {
        selectedRoute = .init(destination: destination)
        preferredCompactColumn = .detail
        detailIdentity = .init()
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
