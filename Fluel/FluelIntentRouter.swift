//
//  FluelIntentRouter.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import Observation

@Observable
final class FluelIntentRouter {
    static let shared = FluelIntentRouter()

    private(set) var destination: FluelDestinationIntentValue?

    private init() {
        // Singleton router for app-intent handoff.
    }

    func open(_ destination: FluelDestinationIntentValue) {
        self.destination = destination
    }

    func consumeDestination() -> FluelDestinationIntentValue? {
        let consumedDestination = destination
        self.destination = nil
        return consumedDestination
    }
}
