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
        startDate: Date,
        precision: FluelStartPrecisionIntentValue,
        note: String,
        modelContainer: ModelContainer
    ) throws -> EntryEntity {
        let input = try EntryInput(
            title: title,
            startDate: startDate,
            startPrecision: precision.startPrecision,
            note: note
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
