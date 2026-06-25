//
//  EntryEditorForm.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import SwiftUI

struct EntryEditorForm: View {
    @Binding var draft: EntryDraft

    var body: some View {
        Form {
            EntryTitleSection(title: $draft.title)

            EntryStartPicker(draft: $draft)
        }
    }
}
