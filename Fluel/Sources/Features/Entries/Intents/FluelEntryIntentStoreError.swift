//
//  FluelEntryIntentStoreError.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import Foundation

enum FluelEntryIntentStoreError: LocalizedError {
    case entryAlreadyArchived
    case entryIsNotArchived
    case entryNotFound

    var errorDescription: String? {
        switch self {
        case .entryAlreadyArchived:
            String(localized: "This entry is already archived.", table: "AppIntents")
        case .entryIsNotArchived:
            String(localized: "This entry is not archived.", table: "AppIntents")
        case .entryNotFound:
            String(localized: "The entry could not be found.", table: "AppIntents")
        }
    }
}
