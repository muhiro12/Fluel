//
//  FluelSectionHeader.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import MHUI
import SwiftUI

struct FluelSectionHeader: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    private let title: Text
    private let supporting: Text?

    var body: some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
            title
                .mhSectionHeaderTitle()

            if let supporting {
                supporting
                    .mhSectionHeaderSupporting()
            }
        }
        .mhSectionHeader()
    }

    init(_ title: LocalizedStringKey) {
        self.title = Text(title)
        supporting = nil
    }

    init(title: Text) {
        self.title = title
        supporting = nil
    }

    init(_ title: LocalizedStringKey, supporting: LocalizedStringKey) {
        self.title = Text(title)
        self.supporting = Text(supporting)
    }
}

#Preview("Section header", traits: .sizeThatFitsLayout) {
    FluelSectionHeader("The quiet overview")
        .padding()
        .mhTheme(.standard)
}
