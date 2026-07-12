//
//  FluelSchemaV1.swift
//  Fluel
//
//  Created by Codex on 2026/07/12.
//

import SwiftData

enum FluelSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            Entry.self,
            EntryActivity.self,
            Preset.self,
            PresetDefaultSelection.self
        ]
    }
}
