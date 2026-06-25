//
//  EntryRowView.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import MHUI
import SwiftUI

struct EntryRowView: View {
    private enum Layout {
        static let horizontalSpacing: CGFloat = 16
        static let minimumTrailingSpacing: CGFloat = 12
    }

    let entry: Entry

    var body: some View {
        HStack(alignment: .center, spacing: Layout.horizontalSpacing) {
            EntryRowText(entry: entry)

            Spacer(minLength: Layout.minimumTrailingSpacing)

            Text(entry.timeTogether().primaryText)
                .mhRowValue(colorRole: .accent)
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    EntryRowView(entry: PreviewSampleData.sampleEntries[1])
        .mhTheme(.standard)
        .padding()
}
