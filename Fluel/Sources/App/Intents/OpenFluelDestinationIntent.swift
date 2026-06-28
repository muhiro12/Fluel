//
//  OpenFluelDestinationIntent.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import AppIntents
import FluelLibrary

struct OpenFluelDestinationIntent: AppIntent {
    static let title = LocalizedStringResource("Open Fluel Destination", table: "AppIntents")
    static let description = IntentDescription(
        LocalizedStringResource("Open Fluel to a main screen.", table: "AppIntents")
    )
    static let openAppWhenRun = true
    static let isDiscoverable = false

    @Parameter(title: LocalizedStringResource("Destination", table: "AppIntents"))
    private var destination: FluelDestinationIntentValue

    @MainActor
    func perform() async -> some IntentResult {
        await FluelIntentRouteOpener.store(
            .destination(destination.linkDestination)
        )
        return .result()
    }
}
