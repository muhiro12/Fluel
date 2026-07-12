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
        let entry = Entry(input: input)
        let modelContext = modelContainer.mainContext

        try modelContext.performAndSave {
            modelContext.insert(entry)
        }

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

        let snapshot = EntryOperations.archive(
            entry.snapshot,
            archivedAt: .now
        )
        let modelContext = modelContainer.mainContext

        try modelContext.performAndSave {
            entry.apply(snapshot)
        }
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

        let snapshot = EntryOperations.restore(
            entry.snapshot,
            restoredAt: .now
        )
        let modelContext = modelContainer.mainContext

        try modelContext.performAndSave {
            entry.apply(snapshot)
        }
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
        let identifier = entity.id
        let descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate<Entry> { entry in
                entry.id.uuidString == identifier
            }
        )

        guard let entry = try modelContainer.mainContext.fetch(descriptor).first else {
            throw FluelEntryIntentStoreError.entryNotFound
        }

        return entry
    }
}
