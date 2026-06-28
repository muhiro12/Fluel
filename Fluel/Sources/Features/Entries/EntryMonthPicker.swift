//
//  EntryMonthPicker.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import SwiftUI

struct EntryMonthPicker: View {
    @Binding var draft: EntryDraft

    let calendar: Calendar

    var body: some View {
        Picker("Month", selection: $draft.month) {
            ForEach(draft.availableMonths(calendar: calendar), id: \.self) { month in
                Text(StartPrecision.monthName(for: month, calendar: calendar))
                    .tag(month)
            }
        }
    }
}
