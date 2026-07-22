//
//  FluelEntryIntentStore.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import FluelLibrary
import Foundation
import SwiftData

enum FluelEntryIntentStore {
    @MainActor
    static func createEntry(
        title: String,
        start: EntryStart,
        note: String,
        calendar: Calendar,
        modelContainer: ModelContainer
    ) throws -> EntryEntity {
        let input = try EntryInput(
            title: title,
            start: start,
            note: note,
            calendar: calendar
        )
        let modelContext = modelContainer.mainContext
        let entry = try EntryStore.create(
            input: input,
            photoData: nil,
            createdAt: .now,
            in: modelContext
        )

        return .init(entry: entry)
    }

    @MainActor
    static func archive(
        _ entity: EntryEntity,
        modelContainer: ModelContainer
    ) throws {
        let entry = try entry(for: entity, modelContainer: modelContainer)

        guard !entry.isArchived else {
            throw FluelEntryIntentStoreError.entryAlreadyArchived
        }

        let modelContext = modelContainer.mainContext
        try EntryStore.archive(
            entry,
            archivedAt: .now,
            in: modelContext
        )
    }

    @MainActor
    static func restore(
        _ entity: EntryEntity,
        modelContainer: ModelContainer
    ) throws {
        let entry = try entry(for: entity, modelContainer: modelContainer)

        guard entry.isArchived else {
            throw FluelEntryIntentStoreError.entryIsNotArchived
        }

        let modelContext = modelContainer.mainContext
        try EntryStore.restore(
            entry,
            restoredAt: .now,
            in: modelContext
        )
    }

    @MainActor
    static func timeTogether(
        for entity: EntryEntity,
        modelContainer: ModelContainer
    ) throws -> String {
        let entry = try entry(for: entity, modelContainer: modelContainer)

        return EntryOperations.timeTogether(for: entry.snapshot).primaryText
    }

    @MainActor
    private static func entry(
        for entity: EntryEntity,
        modelContainer: ModelContainer
    ) throws -> Entry {
        guard let identifier = UUID(uuidString: entity.id) else {
            throw FluelEntryIntentStoreError.entryNotFound
        }

        var descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate<Entry> { entry in
                entry.id == identifier
            }
        )
        descriptor.fetchLimit = 1

        guard let entry = try modelContainer.mainContext.fetch(descriptor).first else {
            throw FluelEntryIntentStoreError.entryNotFound
        }

        return entry
    }
}
