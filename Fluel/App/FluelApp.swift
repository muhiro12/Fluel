//
//  FluelApp.swift
//  Fluel
//
//  Created by Hiromu Nakano on 2026/03/07.
//

import FluelLibrary
import MHPlatform
import SwiftData
import SwiftUI

@main
struct FluelApp: App {
    private let bootstrap: FluelAppBootstrap
    private let startupLogger = FluelAppLogging.logger(category: "AppStartup")

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modelContainer(bootstrap.modelContainer)
                .environment(bootstrap.appRuntime)
        }
    }

    @MainActor
    init() {
        startupLogger.notice("app startup began")
        bootstrap = .live()
        startupLogger.notice("startup dependencies ready")
        startupLogger.notice("startup wiring finished")
    }
}
