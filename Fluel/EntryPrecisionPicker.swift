//
//  EntryPrecisionPicker.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import SwiftUI

struct EntryPrecisionPicker: View {
    @Binding var draft: EntryEditorDraft

    let calendar: Calendar

    var body: some View {
        Picker("Precision", selection: $draft.precision) {
            ForEach(StartPrecision.allCases) { precision in
                Text(precision.label)
                    .tag(precision)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: draft.precision) {
            draft.alignComponentsWithPrecision(calendar: calendar)
        }
    }
}
