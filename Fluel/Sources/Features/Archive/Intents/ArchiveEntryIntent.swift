//
//  ArchiveEntryIntent.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import AppIntents
import SwiftData

struct ArchiveEntryIntent: AppIntent {
    static let title = LocalizedStringResource("Archive Entry", table: "AppIntents")
    static let description = IntentDescription(
        LocalizedStringResource("Move an entry out of daily life.", table: "AppIntents")
    )
    static let supportedModes: IntentModes = .background
    static let isDiscoverable = false

    @Parameter(title: LocalizedStringResource("Entry", table: "AppIntents"))
    private var entry: EntryEntity

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ProvidesDialog {
        try FluelEntryIntentStore.archive(
            entry,
            modelContainer: modelContainer
        )

        return .result(
            dialog: IntentDialog(LocalizedStringResource("Archived entry.", table: "AppIntents"))
        )
    }
}
