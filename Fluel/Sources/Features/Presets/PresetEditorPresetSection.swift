//
//  PresetEditorPresetSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import MHUI
import SwiftUI

struct PresetEditorPresetSection: View {
    @Binding var title: String
    @Binding var note: String
    @Binding var symbolOption: PresetSymbolOption

    let noteLineLimit: ClosedRange<Int>

    var body: some View {
        Section {
            TextField("Thing or place", text: $title)
                .textInputAutocapitalization(.words)

            Picker("Visual cue", selection: $symbolOption) {
                ForEach(PresetSymbolOption.allCases) { option in
                    Label(option.label, systemImage: option.symbolName)
                        .tag(option)
                }
            }

            TextField("Small memory or detail", text: $note, axis: .vertical)
                .lineLimit(noteLineLimit)
        } header: {
            FluelSectionHeader("Preset")
        }
    }
}
