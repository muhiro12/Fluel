//
//  EntryDetailHeader.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import MHUI
import SwiftUI

struct EntryDetailHeader: View {
    private enum Layout {
        static let verticalSpacing: CGFloat = 12
        static let verticalPadding: CGFloat = 8
    }

    let entry: Entry

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: Layout.verticalSpacing) {
                Text("Time together")
                    .mhRowOverline()

                Text(entry.timeTogether().primaryText)
                    .mhTextStyle(.screenTitle, colorRole: .accent)

                if let supportingText = entry.timeTogether().supportingText {
                    Text(supportingText)
                        .mhRowSupporting()
                }
            }
            .padding(.vertical, Layout.verticalPadding)
        }
    }
}
