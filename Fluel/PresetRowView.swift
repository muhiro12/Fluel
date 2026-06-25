//
//  PresetRowView.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import MHUI
import SwiftUI

struct PresetRowView: View {
    private enum Layout {
        static let horizontalSpacing: CGFloat = 12
        static let verticalSpacing: CGFloat = 6
    }

    let preset: EntryPreset
    let canEdit: Bool
    let use: () -> Void
    let edit: () -> Void
    let delete: () -> Void
    let togglePin: () -> Void
    let toggleDefault: () -> Void

    var body: some View {
        HStack(spacing: Layout.horizontalSpacing) {
            Image(systemName: preset.symbolName)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Layout.verticalSpacing) {
                Text(preset.title)
                    .mhRowTitle()

                Text(preset.startPrecision.knownAsText)
                    .mhRowSupporting()

                badges
            }

            Spacer()

            Button("Use", action: use)

            Menu {
                Button(preset.isPinned ? "Unpin" : "Pin", action: togglePin)
                Button(preset.isDefault ? "Clear default" : "Set as default", action: toggleDefault)

                if canEdit {
                    Button("Edit", action: edit)
                    Button("Delete", role: .destructive, action: delete)
                }
            } label: {
                Label("Preset Actions", systemImage: "ellipsis.circle")
            }
        }
    }

    private var badges: some View {
        HStack {
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
