//
//  FluelModelContainerFactory.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import SwiftData

enum FluelModelContainerFactory {
    static let cloudKitContainerIdentifier = "iCloud.com.muhiro12.Fluel"

    private static let storeName = "FluelV1"

    static let schema = Schema(versionedSchema: FluelSchemaV1.self)

    static func production() throws -> ModelContainer {
        try ModelContainer(
            for: schema,
            migrationPlan: FluelSchemaMigrationPlan.self,
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
            migrationPlan: FluelSchemaMigrationPlan.self,
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
