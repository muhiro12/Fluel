//
//  RestoreEntryIntent.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import AppIntents
import SwiftData

struct RestoreEntryIntent: AppIntent {
    static let title = LocalizedStringResource("Restore Entry", table: "AppIntents")
    static let description = IntentDescription(
        LocalizedStringResource("Move an archived entry back into daily life.", table: "AppIntents")
    )
    static let supportedModes: IntentModes = .background

    @Parameter(title: LocalizedStringResource("Entry", table: "AppIntents"))
    private var entry: EntryEntity

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ProvidesDialog {
        try FluelEntryIntentStore.restore(
            entry,
            modelContainer: modelContainer
        )

        return .result(
            dialog: IntentDialog(LocalizedStringResource("Restored entry.", table: "AppIntents"))
        )
    }
}
