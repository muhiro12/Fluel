//
//  PresetRowIdentity.swift
//  Fluel
//
//  Created by Codex on 2026/07/17.
//

import FluelLibrary
import MHUI
import SwiftUI

struct PresetRowIdentity: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let preset: EntryPreset

    var body: some View {
        HStack(alignment: .top, spacing: designMetrics.spacing.control) {
            Image(systemName: preset.symbolName)
                .mhTextStyle(.sectionTitle, colorRole: .secondaryText)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                Text(verbatim: preset.displayTitle)
                    .mhRowTitle()

                Text(preset.startPrecision.knownAsText)
                    .mhRowSupporting()

                FluelBadgeStack {
                    if preset.isPinned {
                        Text("Pinned")
                            .mhBadge(style: .neutral, accessibilityLabel: Text("Pinned preset"))
                    }

                    if preset.isDefault {
                        Text("Default")
                            .mhBadge(style: .neutral, accessibilityLabel: Text("Default preset"))
                    }

                    if preset.lastUsedAt != nil {
                        Text("Recent")
                            .mhBadge(style: .neutral, accessibilityLabel: Text("Recent preset"))
                    }
                }
            }
        }
    }
}
