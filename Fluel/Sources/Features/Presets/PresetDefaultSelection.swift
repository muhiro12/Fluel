//
//  PresetDefaultSelection.swift
//  Fluel
//
//  Created by Codex on 2026/07/12.
//

import Foundation
import SwiftData

@Model
final class PresetDefaultSelection {
    var id = UUID()
    var presetID: UUID?
    var selectedAt = Date()

    init(
        presetID: UUID?,
        selectedAt: Date,
        id: UUID
    ) {
        self.id = id
        self.presetID = presetID
        self.selectedAt = selectedAt
    }

    convenience init(
        presetID: UUID?,
        selectedAt: Date
    ) {
        self.init(
            presetID: presetID,
            selectedAt: selectedAt,
            id: .init()
        )
    }

    convenience init(presetID: UUID?) {
        self.init(presetID: presetID, selectedAt: .now)
    }
}
