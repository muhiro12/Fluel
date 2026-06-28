//
//  FluelIntentRouteOpener.swift
//  Fluel
//
//  Created by Codex on 2026/06/28.
//

import FluelLibrary
import Foundation

enum FluelIntentRouteOpener {
    static func routeIntent(for link: FluelLink) -> OpenFluelRouteIntent {
        .init(url: FluelLinkOperations.url(for: link))
    }

    @MainActor
    static func store(_ link: FluelLink) async {
        await FluelIntentRouteStore.store(
            FluelLinkOperations.url(for: link)
        )
    }
}
