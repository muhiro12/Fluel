//
//  OpenFluelIntent.swift
//  Fluel
//
//  Created by Codex on 2026/06/28.
//

import AppIntents
import FluelLibrary

struct OpenFluelIntent: AppIntent {
    static let title = LocalizedStringResource("Open Fluel", table: "AppIntents")
    static let description = IntentDescription(
        LocalizedStringResource("Open Fluel to a main screen.", table: "AppIntents")
    )
    static let openAppWhenRun = true

    @MainActor
    func perform() async -> some IntentResult {
        await FluelIntentRouteOpener.store(.destination(.entries))
        return .result()
    }
}
