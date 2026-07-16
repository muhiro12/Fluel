//
//  ContentSidebarRow.swift
//  Fluel
//
//  Created by Codex on 2026/07/16.
//

import SwiftUI

struct ContentSidebarRow: View {
    let route: FluelRoute

    var body: some View {
        NavigationLink(value: route) {
            Label(route.title, systemImage: route.systemImage)
        }
    }
}
