//
//  SampleDataStore.swift
//  Fluel
//
//  Created by Codex on 2026/07/17.
//

import FluelLibrary
import Foundation
import SwiftData

enum SampleDataStore {
    static func installedEntryCount(
        in entries: [Entry]
    ) -> Int {
        let installedEntryIDs = Set(entries.map(\.id))
        return installedEntryIDs.intersection(SampleDataManifest.entryIDs).count
    }

    @MainActor
    static func install(
        existingEntries: [Entry],
        existingActivity: [EntryActivity],
        referenceDate: Date,
        calendar: Calendar,
        in modelContext: ModelContext
    ) throws {
        let definitions = try SampleDataManifest.entries(
            referenceDate: referenceDate,
            calendar: calendar
        )
        let existingEntryIDs = Set(existingEntries.map(\.id))
        var existingActivityIDs = Set(existingActivity.map(\.id))

        try modelContext.performAndSave {
            for definition in definitions where !existingEntryIDs.contains(definition.snapshot.id) {
                modelContext.insert(definition.makeEntry())

                for activityItem in definition.makeActivityItems()
                where !existingActivityIDs.contains(activityItem.id) {
                    modelContext.insert(activityItem)
                    existingActivityIDs.insert(activityItem.id)
                }
            }
        }
    }

    @MainActor
    static func remove(
        existingEntries: [Entry],
        existingActivity: [EntryActivity],
        in modelContext: ModelContext
    ) throws {
        let sampleEntryIDs = SampleDataManifest.entryIDs
        let entries = existingEntries.filter { entry in
            sampleEntryIDs.contains(entry.id)
        }
        let activity = existingActivity.filter { activityItem in
            sampleEntryIDs.contains(activityItem.entryID)
        }

        try modelContext.performAndSave {
            for activityItem in activity {
                modelContext.delete(activityItem)
            }

            for entry in entries {
                modelContext.delete(entry)
            }
        }
    }
}
