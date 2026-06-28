//
//  EntryEntity.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import AppIntents
import FluelLibrary

struct EntryEntity: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource("Entry", table: "AppIntents")
    )

    static let defaultQuery = EntryEntityQuery()

    let id: String
    let title: String
    let startLabel: String
    let isArchived: Bool

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(startLabel)"
        )
    }

    init(entry: Entry) {
        id = entry.id.uuidString
        title = entry.title
        startLabel = entry.startPrecision.startLabel(for: entry.startDate)
        isArchived = entry.isArchived
    }
}
