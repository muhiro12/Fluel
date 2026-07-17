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
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    let preset: EntryPreset
    let canEdit: Bool
    let use: () -> Void
    let edit: () -> Void
    let delete: () -> Void
    let togglePin: () -> Void
    let toggleDefault: () -> Void

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(
                alignment: .leading,
                spacing: designMetrics.spacing.control
            ))
            : AnyLayout(HStackLayout(
                alignment: .center,
                spacing: designMetrics.spacing.control
            ))

        layout {
            PresetRowIdentity(preset: preset)
                .frame(maxWidth: .infinity, alignment: .leading)
            actions
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
