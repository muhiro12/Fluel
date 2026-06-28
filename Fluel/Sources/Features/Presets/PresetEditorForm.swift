//
//  PresetEditorForm.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import SwiftUI

struct PresetEditorForm: View {
    @Binding var title: String
    @Binding var note: String
    @Binding var symbolOption: PresetSymbolOption
    @Binding var startOption: PresetStartOption
    @Binding var precision: StartPrecision

    let noteLineLimit: ClosedRange<Int>

    var body: some View {
        Form {
            PresetEditorPresetSection(
                title: $title,
                note: $note,
                symbolOption: $symbolOption,
                noteLineLimit: noteLineLimit
            )

            PresetEditorStartSection(
                startOption: $startOption,
                precision: $precision
            )
        }
    }
}
