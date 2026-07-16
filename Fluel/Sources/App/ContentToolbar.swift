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
        ToolbarItem(placement: .primaryAction) {
            Button(action: addEntry) {
                Label("Add Entry", systemImage: "plus")
            }
        }
    }
}
