//
//  PresetEditorStartSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import MHUI
import SwiftUI

struct PresetEditorStartSection: View {
    @Binding var startOption: PresetStartOption
    @Binding var precision: StartPrecision

    var body: some View {
        Section {
            Picker("Start", selection: $startOption) {
                ForEach(PresetStartOption.allCases) { option in
                    Text(option.label)
                        .tag(option)
                }
            }

            Picker("Precision", selection: $precision) {
                ForEach(StartPrecision.allCases) { precision in
                    Text(precision.knownAsText)
                        .tag(precision)
                }
            }
        } header: {
            MHSectionHeader("Start")
        }
    }
}
