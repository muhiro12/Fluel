//
//  FluelEmptyState.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import MHUI
import SwiftUI

struct FluelEmptyState<Actions: View>: View {
    private let title: LocalizedStringKey
    private let systemImage: String
    private let description: LocalizedStringKey
    private let actions: () -> Actions

    var body: some View {
        ContentUnavailableView {
            Label {
                Text(title)
            } icon: {
                Image(systemName: systemImage)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.accentColor)
            }
        } description: {
            Text(description)
        } actions: {
            actions()
        }
        .mhEmptyStateLayout()
    }

    init(
        _ title: LocalizedStringKey,
        systemImage: String,
        description: LocalizedStringKey,
        @ViewBuilder actions: @escaping () -> Actions
    ) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
        self.actions = actions
    }
}

extension FluelEmptyState where Actions == EmptyView {
    init(
        _ title: LocalizedStringKey,
        systemImage: String,
        description: LocalizedStringKey
    ) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
        actions = {
            EmptyView()
        }
    }
}

#Preview("Empty state - action", traits: .sizeThatFitsLayout) {
    FluelEmptyState(
        "Begin with one entry",
        systemImage: "clock",
        description: "Add one thing or place you live with and keep the start as precisely as you know it."
    ) {
        Button("Add Entry") {
            _ = "Preview action"
        }
        .buttonStyle(.mhPrimary)
    }
    .padding()
    .mhTheme(.standard)
}

#Preview("Empty state - no action", traits: .sizeThatFitsLayout) {
    FluelEmptyState(
        "Timeline",
        systemImage: "clock.arrow.circlepath",
        description: "Activity will gather as entries are added, adjusted, and archived."
    )
    .padding()
    .mhTheme(.standard)
}
