//
//  CreateEntryIntent.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import AppIntents
import Foundation
import SwiftData

struct CreateEntryIntent: AppIntent {
    static let title = LocalizedStringResource("Create Entry", table: "AppIntents")
    static let description = IntentDescription(
        LocalizedStringResource("Create an entry with a known start.", table: "AppIntents")
    )
    static let supportedModes: IntentModes = .background

    @Parameter(title: LocalizedStringResource("Title", table: "AppIntents"))
    private var title: String

    @Parameter(title: LocalizedStringResource("Start", table: "AppIntents"), kind: .date)
    private var startDate: Date

    @Parameter(title: LocalizedStringResource("Precision", table: "AppIntents"))
    private var precision: FluelStartPrecisionIntentValue

    @Parameter(title: LocalizedStringResource("Note", table: "AppIntents"), default: "")
    private var note: String

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<EntryEntity> & ProvidesDialog {
        let entry = try FluelEntryIntentStore.createEntry(
            title: title,
            startDate: startDate,
            precision: precision,
            note: note,
            modelContainer: modelContainer
        )

        return .result(
            value: entry,
            dialog: IntentDialog(LocalizedStringResource("Created entry.", table: "AppIntents"))
        )
    }
}
