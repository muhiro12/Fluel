//
//  FluelIntentRouteStore.swift
//  Fluel
//
//  Created by Codex on 2026/06/28.
//

import Foundation
import MHPlatform

enum FluelIntentRouteStore {
    static let storageDescriptor = MHRawStorageDescriptor(
        storageKey: "com.muhiro12.Fluel.pendingDeepLinkURL",
        defaultSelection: .standard
    )

    private static let deepLinkStore = MHDeepLinkStore(
        key: storageDescriptor
    )

    static var source: MHDeepLinkStore? {
        deepLinkStore
    }

    @MainActor private static var liveRoutePipeline: FluelRoutePipeline?

    @MainActor
    static func registerLiveRoutePipeline(
        _ routePipeline: FluelRoutePipeline
    ) {
        liveRoutePipeline = routePipeline
    }

    @MainActor
    static func store(_ url: URL) async {
        deepLinkStore.ingest(url)
        await liveRoutePipeline?.synchronizePendingRoutesIfPossible()
    }
}
