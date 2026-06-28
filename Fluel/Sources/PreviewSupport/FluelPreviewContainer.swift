//
//  FluelPreviewContainer.swift
//  Fluel
//
//  Created by Codex on 2026/06/28.
//

import MHUI
import SwiftData
import SwiftUI

@MainActor
struct FluelPreviewContainer<Content: View>: View {
    private let platformEnvironment: FluelPlatformEnvironment
    private let content: () -> Content

    var body: some View {
        content()
            .fluelPreviewPlatformEnvironment(platformEnvironment)
            .mhTheme(.standard)
    }

    init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        let modelContainer = PreviewSampleData.container(for: .typical)
        platformEnvironment = Self.makePlatformEnvironment(
            modelContainer: modelContainer
        )
        self.content = content
    }

    init(
        _ scenario: PreviewSampleData.Scenario,
        @ViewBuilder content: @escaping () -> Content
    ) {
        let modelContainer = PreviewSampleData.container(for: scenario)
        platformEnvironment = Self.makePlatformEnvironment(
            modelContainer: modelContainer
        )
        self.content = content
    }

    private static func makePlatformEnvironment(
        modelContainer: ModelContainer
    ) -> FluelPlatformEnvironment {
        FluelPlatformEnvironmentFactory.make(
            modelContainer: modelContainer,
            platformMode: .preview,
            logging: FluelLogging.makeBootstrap()
        )
    }
}
