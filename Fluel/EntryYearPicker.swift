//
//  EntryYearPicker.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import SwiftUI

struct EntryYearPicker: View {
    @Binding var draft: EntryEditorDraft

    let calendar: Calendar

    var body: some View {
        Picker("Year", selection: $draft.year) {
            ForEach(draft.availableYears(calendar: calendar), id: \.self) { year in
                Text(String(year))
                    .tag(year)
            }
        }
    }
}
