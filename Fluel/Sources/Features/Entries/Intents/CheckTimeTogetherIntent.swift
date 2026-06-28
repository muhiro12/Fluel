//
//  CheckTimeTogetherIntent.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import AppIntents
import SwiftData

struct CheckTimeTogetherIntent: AppIntent {
    static let title = LocalizedStringResource("Check Time Together", table: "AppIntents")
    static let description = IntentDescription(
        LocalizedStringResource("Check how long an entry has been with you.", table: "AppIntents")
    )
    static let supportedModes: IntentModes = .background

    @Parameter(title: LocalizedStringResource("Entry", table: "AppIntents"))
    private var entry: EntryEntity

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<String> & ProvidesDialog {
        let timeTogether = try FluelEntryIntentStore.timeTogether(
            for: entry,
            modelContainer: modelContainer
        )

        return .result(
            value: timeTogether,
            dialog: IntentDialog(LocalizedStringResource("Time together is ready.", table: "AppIntents"))
        )
    }
}
