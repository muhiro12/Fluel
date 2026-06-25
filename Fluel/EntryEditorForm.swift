//
//  EntryEditorForm.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import SwiftUI

struct EntryEditorForm: View {
    @Binding var draft: EntryEditorDraft

    var body: some View {
        Form {
            EntryTitleSection(title: $draft.title)

            EntryStartPicker(draft: $draft)
        }
    }
}
