//
//  DashboardDetailsSection.swift
//  Fluel
//
//  Created by Codex on 2026/07/23.
//

import MHUI
import SwiftUI

struct DashboardDetailsSection: View {
    let noteCount: Int
    let photoCount: Int

    var body: some View {
        MHGroupedRows {
            LabeledContent("With note", value: noteCount.formatted())
                .labeledContentStyle(.mhKeyValue)

            LabeledContent("With photo", value: photoCount.formatted())
                .labeledContentStyle(.mhKeyValue)
        }
        .mhSection(
            "Details",
            supporting: "Supporting context stays quieter than the entry total."
        )
    }
}
