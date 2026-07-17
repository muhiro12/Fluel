//
//  EntryNoteDetailSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import MHUI
import SwiftUI

struct EntryNoteDetailSection: View {
    let note: String?

    var body: some View {
        if let note {
            Text(note)
                .mhSection("Note")
        }
    }
}
