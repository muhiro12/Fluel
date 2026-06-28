//
//  FluelPlatformEnvironmentFactory.swift
//  Fluel
//
//  Created by Codex on 2026/06/28.
//

import FluelLibrary
import Foundation
import MHPlatform
import SwiftData

enum FluelPlatformEnvironmentFactory {
    @MainActor
    static func make(
        modelContainer: ModelContainer,
        platformMode: FluelPlatformMode,
        logging: MHLoggingBootstrap
    ) -> FluelPlatformEnvironment {
        let routeInbox = makeRouteInbox()
        let routePipeline = makeRoutePipeline(
            routeInbox: routeInbox,
            logging: logging
        )
        FluelIntentRouteStore.registerLiveRoutePipeline(routePipeline)

        return .init(
            logging: logging,
            modelContainer: modelContainer,
            routeInbox: routeInbox,
            routePipeline: routePipeline,
            runtimeBootstrap: makeRuntimeBootstrap(
                configuration: makeAppConfiguration(for: platformMode),
                routePipeline: routePipeline
            )
        )
    }

    private static func makeAppConfiguration(
        for platformMode: FluelPlatformMode
    ) -> MHAppConfiguration {
        switch platformMode {
        case .production:
            .init(showsLicenses: true)
        case .preview:
            .init(showsLicenses: false)
        }
    }

    @MainActor
    private static func makeRouteInbox() -> FluelRouteInbox {
        .init(
            isDuplicate: { route, otherRoute in
                route == otherRoute
            },
            onFailure: { _, error in
                assertionFailure(error.localizedDescription)
            }
        )
    }

    @MainActor
    private static func makeRoutePipeline(
        routeInbox: FluelRouteInbox,
        logging: MHLoggingBootstrap
    ) -> FluelRoutePipeline {
        let routeLogger = FluelLogging.logger(
            logging: logging,
            category: FluelLogging.Category.routeExecution,
            source: #fileID
        )
        let isDuplicate: MHRouteLifecycle<FluelLink>.DuplicatePredicate = { route, otherRoute in
            route == otherRoute
        }
        let parseRoute: FluelRoutePipeline.RouteParser = { incomingURL in
            switch FluelLinkOperations.parse(incomingURL) {
            case .supported(let link):
                link
            case .unsupported:
                nil
            }
        }
        let handleFailure: FluelRoutePipeline.FailureHandler = { error in
            handleRoutePipelineFailure(
                error,
                logger: routeLogger
            )
        }

        return MHAppRoutePipeline(
            routeLifecycle: MHRouteLifecycle<FluelLink>(
                logger: routeLogger,
                initialReadiness: false,
                isDuplicate: isDuplicate
            ),
            parse: parseRoute,
            routeInbox: routeInbox,
            pendingSources: pendingURLSources(),
            onFailure: handleFailure
        )
    }

    @MainActor
    private static func handleRoutePipelineFailure(
        _ error: any Error,
        logger: MHLogger
    ) {
        logger.error(
            "route_pipeline.failure",
            metadata: FluelLogging.errorMetadata(error)
        )
        assertionFailure(error.localizedDescription)
    }

    private static func pendingURLSources() -> [any MHDeepLinkURLSource] {
        var sources = [any MHDeepLinkURLSource]()

        if let intentRouteSource = FluelIntentRouteStore.source {
            sources.append(intentRouteSource)
        }

        return sources
    }

    @MainActor
    private static func makeRuntimeBootstrap(
        configuration: MHAppConfiguration,
        routePipeline: FluelRoutePipeline
    ) -> MHAppRuntimeBootstrap {
        .init(
            runtimeOnlyConfiguration: configuration,
            routePipeline: routePipeline,
            lifecyclePlan: .init(
                commonTasks: [
                    routePipeline.task(name: "synchronizePendingRoutes")
                ]
            )
        )
    }
}
