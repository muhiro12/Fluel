//
//  OpenFluelDestinationIntent.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import AppIntents

struct OpenFluelDestinationIntent: AppIntent {
    static let title = LocalizedStringResource("Open Fluel", table: "AppIntents")
    static let description = IntentDescription(
        LocalizedStringResource("Open Fluel to a main screen.", table: "AppIntents")
    )
    static let supportedModes: IntentModes = .foreground(.immediate)

    @Parameter(title: LocalizedStringResource("Destination", table: "AppIntents"))
    private var destination: FluelDestinationIntentValue

    @MainActor
    func perform() -> some IntentResult {
        FluelIntentRouter.shared.open(destination)
        return .result()
    }
}
