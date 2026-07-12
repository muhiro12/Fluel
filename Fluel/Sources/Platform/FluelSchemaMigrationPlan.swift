//
//  FluelSchemaMigrationPlan.swift
//  Fluel
//
//  Created by Codex on 2026/07/12.
//

import SwiftData

enum FluelSchemaMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [FluelSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
