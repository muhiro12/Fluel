//
//  EntryStartPrecisionTip.swift
//  Fluel
//
//  Created by Codex on 2026/07/16.
//

import SwiftUI
import TipKit

struct EntryStartPrecisionTip: Tip {
    var title: Text {
        Text(
            "Choose the precision you know",
            comment: "Title of the one-time tip shown beside the entry start precision picker."
        )
    }

    var message: Text? {
        Text(
            "Use a day, month, or year. Month and year starts stay approximate.",
            comment: "Message explaining how entry start precision preserves uncertainty."
        )
    }

    var image: Image? {
        Image(systemName: "calendar")
    }

    var options: [Option] {
        MaxDisplayCount(1)
    }
}
