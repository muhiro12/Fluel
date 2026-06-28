//
//  EntryNoteDetailSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import SwiftUI

struct EntryNoteDetailSection: View {
    let note: String?

    var body: some View {
        if let note {
            Section("Note") {
                Text(note)
            }
        }
    }
}
