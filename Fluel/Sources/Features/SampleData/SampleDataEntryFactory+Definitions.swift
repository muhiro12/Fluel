//
//  SampleDataEntryFactory+Definitions.swift
//  Fluel
//
//  Created by Codex on 2026/07/17.
//

import FluelLibrary
import Foundation

extension SampleDataEntryFactory {
    static func thisHome(
        referenceDate: Date,
        calendar: Calendar
    ) throws -> SampleDataManifest.EntryDefinition {
        try definition(
            EntryValue(
                id: SampleDataManifest.Identifier.thisHome,
                title: String(
                    localized: "This home",
                    table: "SampleData",
                    bundle: .main,
                    comment: "Title for the sample home entry."
                ),
                note: String(
                    localized: "A home is where daily life gathers.",
                    table: "SampleData",
                    bundle: .main,
                    comment: "Note for the sample home entry."
                ),
                photoData: nil,
                startDate: offset(
                    .year,
                    value: DateOffset.thisHomeStartYears,
                    from: referenceDate,
                    calendar: calendar
                ),
                startPrecision: .year,
                createdAt: offset(
                    .day,
                    value: DateOffset.thisHomeCreatedDays,
                    from: referenceDate,
                    calendar: calendar
                ),
                archivedAt: nil
            ),
            addedActivityID: ActivityIdentifier.thisHomeAdded,
            calendar: calendar,
            archivedActivityID: nil
        )
    }

    static func notebook(
        referenceDate: Date,
        calendar: Calendar
    ) throws -> SampleDataManifest.EntryDefinition {
        try definition(
            EntryValue(
                id: SampleDataManifest.Identifier.notebook,
                title: String(
                    localized: "Notebook",
                    table: "SampleData",
                    bundle: .main,
                    comment: "Title for the sample notebook entry."
                ),
                note: String(
                    localized: "Ordinary thoughts gathered over time.",
                    table: "SampleData",
                    bundle: .main,
                    comment: "Note for the sample notebook entry."
                ),
                photoData: nil,
                startDate: offset(
                    .month,
                    value: DateOffset.notebookStartMonths,
                    from: referenceDate,
                    calendar: calendar
                ),
                startPrecision: .month,
                createdAt: offset(
                    .day,
                    value: DateOffset.notebookCreatedDays,
                    from: referenceDate,
                    calendar: calendar
                ),
                archivedAt: nil
            ),
            addedActivityID: ActivityIdentifier.notebookAdded,
            calendar: calendar,
            archivedActivityID: nil
        )
    }

    static func watch(
        referenceDate: Date,
        calendar: Calendar
    ) throws -> SampleDataManifest.EntryDefinition {
        try definition(
            EntryValue(
                id: SampleDataManifest.Identifier.watch,
                title: String(
                    localized: "Watch",
                    table: "SampleData",
                    bundle: .main,
                    comment: "Title for the sample watch entry."
                ),
                note: "",
                photoData: SampleDataManifest.samplePhotoData,
                startDate: offset(
                    .day,
                    value: DateOffset.watchStartDays,
                    from: referenceDate,
                    calendar: calendar
                ),
                startPrecision: .day,
                createdAt: offset(
                    .day,
                    value: DateOffset.watchCreatedDays,
                    from: referenceDate,
                    calendar: calendar
                ),
                archivedAt: nil
            ),
            addedActivityID: ActivityIdentifier.watchAdded,
            calendar: calendar,
            archivedActivityID: nil
        )
    }

    static func deskLamp(
        referenceDate: Date,
        calendar: Calendar
    ) throws -> SampleDataManifest.EntryDefinition {
        try definition(
            EntryValue(
                id: SampleDataManifest.Identifier.deskLamp,
                title: String(
                    localized: "Desk lamp",
                    table: "SampleData",
                    bundle: .main,
                    comment: "Title for the sample desk lamp entry."
                ),
                note: String(
                    localized: "Moved to storage.",
                    table: "SampleData",
                    bundle: .main,
                    comment: "Note for the archived sample desk lamp entry."
                ),
                photoData: nil,
                startDate: offset(
                    .year,
                    value: DateOffset.deskLampStartYears,
                    from: referenceDate,
                    calendar: calendar
                ),
                startPrecision: .day,
                createdAt: offset(
                    .day,
                    value: DateOffset.deskLampCreatedDays,
                    from: referenceDate,
                    calendar: calendar
                ),
                archivedAt: offset(
                    .day,
                    value: DateOffset.deskLampArchivedDays,
                    from: referenceDate,
                    calendar: calendar
                )
            ),
            addedActivityID: ActivityIdentifier.deskLampAdded,
            calendar: calendar,
            archivedActivityID: ActivityIdentifier.deskLampArchived
        )
    }
}
