//
//  ContentSidebar.swift
//  Fluel
//
//  Created by Codex on 2026/07/16.
//

import MHUI
import SwiftUI

struct ContentSidebar: View {
    @Binding private var selection: FluelRoute?

    var body: some View {
        List(selection: $selection) {
            Section {
                ContentSidebarRow(route: .entries)
            }

            Section {
                ForEach(FluelRoute.overviewRoutes) { route in
                    ContentSidebarRow(route: route)
                }
            }

            Section {
                ForEach(FluelRoute.supportingRoutes) { route in
                    ContentSidebarRow(route: route)
                }
            }
        }
        .mhListChrome()
        .navigationTitle("Fluel")
    }

    init(selection: Binding<FluelRoute?>) {
        _selection = selection
    }
}
