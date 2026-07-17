//
//  EntryNoteSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import MHUI
import SwiftUI

struct EntryNoteSection: View {
    private enum Layout {
        static let minimumLineLimit = 3
        static let maximumLineLimit = 6
    }

    @Binding var note: String

    var body: some View {
        Section {
            TextField("Small memory or detail", text: $note, axis: .vertical)
                .lineLimit(Layout.minimumLineLimit...Layout.maximumLineLimit)
                .submitLabel(.done)
        } header: {
            MHSectionHeader("Note")
        }
    }
}
