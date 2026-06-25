//
//  EntryStartValuePicker.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import SwiftUI

struct EntryStartValuePicker: View {
    @Binding var draft: EntryEditorDraft

    let calendar: Calendar

    var body: some View {
        switch draft.precision {
        case .day:
            DatePicker(
                "Start",
                selection: $draft.dayDate,
                in: ...Date(),
                displayedComponents: .date
            )
        case .month:
            EntryMonthPicker(draft: $draft, calendar: calendar)

            EntryYearPicker(draft: $draft, calendar: calendar)
        case .year:
            EntryYearPicker(draft: $draft, calendar: calendar)
        }
    }
}
