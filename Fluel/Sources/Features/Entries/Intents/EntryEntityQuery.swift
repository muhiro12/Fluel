//
//  EntryEntityQuery.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import AppIntents
import SwiftData

struct EntryEntityQuery: EntityStringQuery {
    private static let suggestionLimit = 12

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func entities(for identifiers: [EntryEntity.ID]) throws -> [EntryEntity] {
        let requestedIdentifiers = Set(identifiers)

        return try entries()
            .filter { entry in
                requestedIdentifiers.contains(entry.id.uuidString)
            }
            .map(EntryEntity.init)
    }

    @MainActor
    func suggestedEntities() throws -> [EntryEntity] {
        try entries()
            .prefix(Self.suggestionLimit)
            .map(EntryEntity.init)
    }

    @MainActor
    func entities(matching string: String) throws -> [EntryEntity] {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedString.isEmpty else {
            return try suggestedEntities()
        }

        return try entries()
            .filter { entry in
                entry.title.localizedCaseInsensitiveContains(trimmedString)
            }
            .map(EntryEntity.init)
    }

    @MainActor
    private func entries() throws -> [Entry] {
        let descriptor = FetchDescriptor<Entry>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        return try modelContainer.mainContext.fetch(descriptor)
    }
}
