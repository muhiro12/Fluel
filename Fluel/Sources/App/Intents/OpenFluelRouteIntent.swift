//
//  OpenFluelRouteIntent.swift
//  Fluel
//
//  Created by Codex on 2026/06/28.
//

import AppIntents
import Foundation

struct OpenFluelRouteIntent: AppIntent {
    static let title = LocalizedStringResource("Open Fluel Route", table: "AppIntents")
    static let openAppWhenRun = true
    static let isDiscoverable = false

    @Parameter(title: LocalizedStringResource("URL", table: "AppIntents"))
    private var url: URL

    init() {
        // Required by AppIntent.
    }

    init(url: URL) {
        self.url = url
    }

    @MainActor
    func perform() async -> some IntentResult {
        await FluelIntentRouteStore.store(url)
        return .result()
    }
}
