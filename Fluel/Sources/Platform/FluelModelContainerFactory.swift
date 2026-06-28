//
//  FluelModelContainerFactory.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import SwiftData

enum FluelModelContainerFactory {
    static let cloudKitContainerIdentifier = "iCloud.com.muhiro12.Fluel"

    private static let storeName = "Fluel"

    static let schema = Schema([
        Entry.self,
        Preset.self
    ])

    static func production() throws -> ModelContainer {
        try ModelContainer(
            for: schema,
            configurations: [
                ModelConfiguration(
                    storeName,
                    schema: schema,
                    cloudKitDatabase: .private(cloudKitContainerIdentifier)
                )
            ]
        )
    }

    static func inMemory() throws -> ModelContainer {
        try ModelContainer(
            for: schema,
            configurations: [
                ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true,
                    cloudKitDatabase: .none
                )
            ]
        )
    }
}
