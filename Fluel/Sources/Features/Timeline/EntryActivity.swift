//
//  EntryActivity.swift
//  Fluel
//
//  Created by Codex on 2026/07/12.
//

import FluelLibrary
import Foundation
import SwiftData

/// One durable, user-visible event in an entry's history.
@Model
final class EntryActivity {
    var id = UUID()
    var entryID = UUID()
    var title = ""
    var kind = EntryActivityKind.added
    var occurredAt = Date()

    var summary: EntryActivitySummary {
        .init(
            entryID: entryID,
            title: title,
            kind: kind,
            date: occurredAt,
            id: id
        )
    }

    init(summary: EntryActivitySummary) {
        id = summary.id
        entryID = summary.entryID
        title = summary.title
        kind = summary.kind
        occurredAt = summary.date
    }
}
