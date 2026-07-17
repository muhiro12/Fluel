//
//  SampleDataManifest+Entries.swift
//  Fluel
//
//  Created by Codex on 2026/07/17.
//

import FluelLibrary
import Foundation

enum SampleDataEntryFactory {
    struct EntryValue {
        let id: UUID
        let title: String
        let note: String
        let photoData: Data?
        let startDate: Date
        let startPrecision: StartPrecision
        let createdAt: Date
        let archivedAt: Date?
    }

    enum ActivityIdentifier {
        static let thisHomeAdded = uuid("30000000-0000-0000-0000-000000000001")
        static let notebookAdded = uuid("30000000-0000-0000-0000-000000000002")
        static let watchAdded = uuid("30000000-0000-0000-0000-000000000003")
        static let deskLampAdded = uuid("30000000-0000-0000-0000-000000000004")
        static let deskLampArchived = uuid("30000000-0000-0000-0000-000000000005")
    }

    enum DateOffset {
        static let thisHomeStartYears = -5
        static let thisHomeCreatedDays = -150
        static let notebookStartMonths = -20
        static let notebookCreatedDays = -90
        static let watchStartDays = -210
        static let watchCreatedDays = -30
        static let deskLampStartYears = -3
        static let deskLampCreatedDays = -120
        static let deskLampArchivedDays = -14
    }

    enum ManifestError: Error {
        case invalidDateOffset
    }

    static func entries(
        referenceDate: Date,
        calendar: Calendar
    ) throws -> [SampleDataManifest.EntryDefinition] {
        var resolvedCalendar = Calendar(identifier: .gregorian)
        resolvedCalendar.timeZone = calendar.timeZone

        return try [
            thisHome(referenceDate: referenceDate, calendar: resolvedCalendar),
            notebook(referenceDate: referenceDate, calendar: resolvedCalendar),
            watch(referenceDate: referenceDate, calendar: resolvedCalendar),
            deskLamp(referenceDate: referenceDate, calendar: resolvedCalendar)
        ]
    }

    static func definition(
        _ value: EntryValue,
        addedActivityID: UUID,
        calendar: Calendar,
        archivedActivityID: UUID?
    ) throws -> SampleDataManifest.EntryDefinition {
        let start = try EntryStart(
            date: value.startDate,
            precision: value.startPrecision,
            timeZone: calendar.timeZone
        )
        let modifiedAt = value.archivedAt ?? value.createdAt
        let snapshot = EntrySnapshot(
            id: value.id,
            title: value.title,
            start: start,
            createdAt: value.createdAt,
            updatedAt: modifiedAt,
            archivedAt: value.archivedAt,
            note: value.note,
            hasPhoto: value.photoData != nil
        )
        var activitySummaries = [
            EntryActivitySummary(
                entryID: value.id,
                title: value.title,
                kind: .added,
                date: value.createdAt,
                id: addedActivityID
            )
        ]

        if let archivedAt = value.archivedAt,
           let archivedActivityID {
            activitySummaries.append(
                EntryActivitySummary(
                    entryID: value.id,
                    title: value.title,
                    kind: .archived,
                    date: archivedAt,
                    id: archivedActivityID
                )
            )
        }

        return SampleDataManifest.EntryDefinition(
            snapshot: snapshot,
            photoData: value.photoData,
            activitySummaries: activitySummaries
        )
    }

    static func offset(
        _ component: Calendar.Component,
        value: Int,
        from date: Date,
        calendar: Calendar
    ) throws -> Date {
        guard let offsetDate = calendar.date(
            byAdding: component,
            value: value,
            to: date
        ) else {
            throw ManifestError.invalidDateOffset
        }

        return offsetDate
    }

    static func uuid(_ value: String) -> UUID {
        guard let identifier = UUID(uuidString: value) else {
            preconditionFailure("Invalid sample activity identifier: \(value)")
        }

        return identifier
    }
}

extension SampleDataManifest {
    static func entries(
        referenceDate: Date,
        calendar: Calendar
    ) throws -> [EntryDefinition] {
        try SampleDataEntryFactory.entries(
            referenceDate: referenceDate,
            calendar: calendar
        )
    }
}
