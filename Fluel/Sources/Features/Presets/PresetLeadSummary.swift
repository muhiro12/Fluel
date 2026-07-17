//
//  PresetLeadSummary.swift
//  Fluel
//
//  Created by Codex on 2026/07/18.
//

import FluelLibrary
import MHUI
import SwiftUI

struct PresetLeadSummary: View {
    let preset: EntryPreset

    var body: some View {
        MHSummary(
            title: Text(verbatim: preset.displayTitle),
            metadata: preset.isDefault ? Text("Default preset") : Text("First preset"),
            supporting: Text(preset.startPrecision.knownAsText)
        ) {
            FluelBadgeStack {
                if preset.isPinned {
                    Text("Pinned")
                        .mhBadge(style: .neutral, accessibilityLabel: Text("Pinned preset"))
                }

                if preset.isDefault {
                    Text("Default")
                        .mhBadge(style: .accent, accessibilityLabel: Text("Default preset"))
                }
            }
        }
    }
}
