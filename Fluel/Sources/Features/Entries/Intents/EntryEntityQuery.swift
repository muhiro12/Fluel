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
        try identifiers.compactMap { identifier in
            guard let id = UUID(uuidString: identifier) else {
                return nil
            }

            var descriptor = FetchDescriptor<Entry>(
                predicate: #Predicate<Entry> { entry in
                    entry.id == id
                }
            )
            descriptor.fetchLimit = 1

            return try modelContainer.mainContext.fetch(descriptor).first.map(EntryEntity.init)
        }
    }

    @MainActor
    func suggestedEntities() throws -> [EntryEntity] {
        try entries(limit: Self.suggestionLimit)
            .map(EntryEntity.init)
    }

    @MainActor
    func entities(matching string: String) throws -> [EntryEntity] {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedString.isEmpty else {
            return try suggestedEntities()
        }

        return try entries(limit: Self.suggestionLimit, matching: trimmedString)
            .map(EntryEntity.init)
    }

    @MainActor
    private func entries(
        limit: Int,
        matching searchText: String? = nil
    ) throws -> [Entry] {
        let predicate = searchText.map { searchText in
            #Predicate<Entry> { entry in
                entry.title.localizedStandardContains(searchText)
            }
        }
        var descriptor = FetchDescriptor<Entry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit

        return try modelContainer.mainContext.fetch(descriptor)
    }
}
