//
//  FluelPlatformEnvironment.swift
//  Fluel
//
//  Created by Codex on 2026/06/28.
//

import FluelLibrary
import MHPlatform
import SwiftData
import SwiftUI

typealias FluelRouteInbox = MHObservableRouteInbox<FluelLink>
typealias FluelRoutePipeline = MHAppRoutePipeline<FluelLink>

struct FluelPlatformEnvironment {
    let logging: MHLoggingBootstrap
    let modelContainer: ModelContainer
    let routeInbox: FluelRouteInbox
    let routePipeline: FluelRoutePipeline
    let runtimeBootstrap: MHAppRuntimeBootstrap
}

extension View {
    func fluelPlatformEnvironment(
        _ environment: FluelPlatformEnvironment
    ) -> some View {
        fluelBasePlatformEnvironment(environment)
            .mhAppRuntimeBootstrap(environment.runtimeBootstrap)
    }

    func fluelPreviewPlatformEnvironment(
        _ environment: FluelPlatformEnvironment
    ) -> some View {
        fluelBasePlatformEnvironment(environment)
            .mhAppRuntimeEnvironment(environment.runtimeBootstrap)
    }

    private func fluelBasePlatformEnvironment(
        _ environment: FluelPlatformEnvironment
    ) -> some View {
        modelContainer(environment.modelContainer)
            .environment(environment.logging)
            .environment(environment.routeInbox)
            .environment(environment.routePipeline)
    }
}
