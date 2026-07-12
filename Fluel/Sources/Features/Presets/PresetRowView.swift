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
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let preset: EntryPreset
    let canEdit: Bool
    let use: () -> Void
    let edit: () -> Void
    let delete: () -> Void
    let togglePin: () -> Void
    let toggleDefault: () -> Void

    var body: some View {
        HStack(spacing: designMetrics.spacing.control) {
            Image(systemName: preset.symbolName)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                Text(verbatim: preset.displayTitle)
                    .mhRowTitle()

                Text(preset.startPrecision.knownAsText)
                    .mhRowSupporting()

                badges
            }

            Spacer(minLength: designMetrics.spacing.inline)

            actions
        }
    }

    private var badges: some View {
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

    private var actions: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: designMetrics.spacing.inline) {
                actionControls
            }

            VStack(spacing: designMetrics.spacing.inline) {
                actionControls
            }
        }
    }

    @ViewBuilder private var actionControls: some View {
        Button(action: use) {
            Text("Use")
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .frame(
            minWidth: designMetrics.layout.control.minimumTouchTarget,
            minHeight: designMetrics.layout.control.minimumTouchTarget
        )

        Menu {
            Button(preset.isPinned ? LocalizedStringKey("Unpin") : LocalizedStringKey("Pin"), action: togglePin)
            Button(
                preset.isDefault ? LocalizedStringKey("Clear default") : LocalizedStringKey("Set as default"),
                action: toggleDefault
            )

            if canEdit {
                Button("Edit", action: edit)
                Button("Delete", role: .destructive, action: delete)
            }
        } label: {
            Label("Preset Actions", systemImage: "ellipsis.circle")
                .labelStyle(.iconOnly)
        }
        .accessibilityLabel(Text("Preset Actions"))
        .frame(
            minWidth: designMetrics.layout.control.minimumTouchTarget,
            minHeight: designMetrics.layout.control.minimumTouchTarget
        )
    }
}
