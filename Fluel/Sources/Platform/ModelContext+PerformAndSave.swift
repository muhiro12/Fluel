//
//  ModelContext+PerformAndSave.swift
//  Fluel
//
//  Created by Codex on 2026/07/12.
//

import SwiftData

extension ModelContext {
    @MainActor
    func performAndSave(_ changes: () throws -> Void) throws {
        do {
            try transaction(block: changes)
        } catch {
            rollback()
            throw error
        }
    }
}
