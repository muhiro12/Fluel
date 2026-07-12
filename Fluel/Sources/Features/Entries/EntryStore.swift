//
//  EntryStore.swift
//  Fluel
//
//  Created by Codex on 2026/07/12.
//

import FluelLibrary
import Foundation
import SwiftData

enum EntryStore {
    struct Update {
        let draft: EntryDraft
        let photoData: Data?
        let updatedAt: Date
        let calendar: Calendar
    }

    @MainActor
    @discardableResult
    static func create(
        input: EntryInput,
        photoData: Data?,
        createdAt: Date,
        in modelContext: ModelContext
    ) throws -> Entry {
        let entry = Entry(
            input: input,
            photoData: photoData,
            createdAt: createdAt,
            updatedAt: createdAt,
            archivedAt: nil,
            id: .init()
        )
        let activity = EntryActivity(summary: EntryOperations.addedActivity(
            for: entry.snapshot
        ))

        try modelContext.performAndSave {
            modelContext.insert(entry)
            modelContext.insert(activity)
        }

        return entry
    }

    @MainActor
    @discardableResult
    static func update(
        _ entry: Entry,
        with update: Update,
        in modelContext: ModelContext
    ) throws -> Bool {
        let currentSnapshot = entry.snapshot
        let updatedSnapshot = try EntryOperations.update(
            currentSnapshot,
            from: update.draft,
            updatedAt: update.updatedAt,
            calendar: update.calendar
        )

        guard entryContentChanged(
            from: currentSnapshot,
            to: updatedSnapshot,
            currentPhotoData: entry.photoData,
            updatedPhotoData: update.photoData
        ) else {
            return false
        }

        let activity = EntryActivity(summary: EntryOperations.updatedActivity(
            for: updatedSnapshot
        ))

        try modelContext.performAndSave {
            entry.apply(updatedSnapshot)
            entry.photoData = update.photoData
            modelContext.insert(activity)
        }

        return true
    }

    @MainActor
    @discardableResult
    static func archive(
        _ entry: Entry,
        archivedAt: Date,
        in modelContext: ModelContext
    ) throws -> Bool {
        let currentSnapshot = entry.snapshot
        let archivedSnapshot = EntryOperations.archive(
            currentSnapshot,
            archivedAt: archivedAt
        )

        guard archivedSnapshot != currentSnapshot,
              let summary = EntryOperations.archivedActivity(for: archivedSnapshot) else {
            return false
        }

        let activity = EntryActivity(summary: summary)

        try modelContext.performAndSave {
            entry.apply(archivedSnapshot)
            modelContext.insert(activity)
        }

        return true
    }

    @MainActor
    @discardableResult
    static func restore(
        _ entry: Entry,
        restoredAt: Date,
        in modelContext: ModelContext
    ) throws -> Bool {
        let currentSnapshot = entry.snapshot
        let restoredSnapshot = EntryOperations.restore(
            currentSnapshot,
            restoredAt: restoredAt
        )

        guard restoredSnapshot != currentSnapshot else {
            return false
        }

        let activity = EntryActivity(summary: EntryOperations.updatedActivity(
            for: restoredSnapshot
        ))

        try modelContext.performAndSave {
            entry.apply(restoredSnapshot)
            modelContext.insert(activity)
        }

        return true
    }

    @MainActor
    static func deletePermanently(
        _ entry: Entry,
        in modelContext: ModelContext
    ) throws {
        let entryID = entry.id
        let activityPredicate = #Predicate<EntryActivity> { activity in
            activity.entryID == entryID
        }

        try modelContext.performAndSave {
            try EntryOperations.validatePermanentDelete(for: entry.snapshot)
            try modelContext.delete(
                model: EntryActivity.self,
                where: activityPredicate
            )
            modelContext.delete(entry)
        }
    }

    private static func entryContentChanged(
        from currentSnapshot: EntrySnapshot,
        to updatedSnapshot: EntrySnapshot,
        currentPhotoData: Data?,
        updatedPhotoData: Data?
    ) -> Bool {
        currentSnapshot.title != updatedSnapshot.title
            || currentSnapshot.note != updatedSnapshot.note
            || currentSnapshot.start != updatedSnapshot.start
            || currentPhotoData != updatedPhotoData
    }
}
