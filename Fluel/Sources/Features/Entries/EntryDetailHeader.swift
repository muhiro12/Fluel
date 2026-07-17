//
//  EntryDetailHeader.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import MHUI
import SwiftUI

struct EntryDetailHeader: View {
    let entry: Entry

    var body: some View {
        let summary = entry.timeTogether()

        MHSummary(
            title: Text(summary.primaryText),
            metadata: Text("Time together"),
            supporting: summary.supportingText.map { supportingText in
                Text(supportingText)
            }
        )
    }
}
