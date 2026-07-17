//
//  PreviewSampleData+Entries.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import Foundation

// swiftlint:disable no_magic_numbers number_separator

extension PreviewSampleData {
    static var samplePhotoData: Data {
        SampleDataManifest.samplePhotoData
    }

    static var sampleEntryDefinitions: [SampleDataManifest.EntryDefinition] {
        do {
            return try SampleDataManifest.entries(
                referenceDate: ReferenceDate.current,
                calendar: Calendar(identifier: .gregorian)
            )
        } catch {
            preconditionFailure("Sample entry definitions are invalid: \(error)")
        }
    }

    static var sampleEntries: [Entry] {
        typicalEntries
    }

    static var typicalEntries: [Entry] {
        sampleEntryDefinitions.map { definition in
            definition.makeEntry()
        }
    }

    static var denseEntries: [Entry] {
        typicalEntries + [
            Entry(
                title: "Wallet",
                note: "Usually one of the first things that leaves with me.",
                photoData: samplePhotoData,
                start: entryStart(year: 2020, precision: .year),
                createdAt: ReferenceDate.created,
                updatedAt: ReferenceDate.current,
                archivedAt: nil,
                id: uuid(Identifier.wallet)
            ),
            Entry(
                title: "Bag",
                note: nil,
                photoData: nil,
                start: entryStart(year: 2024, precision: .month, month: 11),
                createdAt: ReferenceDate.created,
                updatedAt: ReferenceDate.current,
                archivedAt: nil,
                id: uuid(Identifier.bag)
            ),
            Entry(
                title: "Plant",
                note: "Shares the same light near the kitchen window.",
                photoData: nil,
                start: entryStart(year: 2024, precision: .month, month: 3),
                createdAt: ReferenceDate.created,
                updatedAt: ReferenceDate.current,
                archivedAt: nil,
                id: uuid(Identifier.plant)
            ),
            Entry(
                title: "Small wooden chair that moved through different rooms",
                note: """
                Furniture can stay through different rooms. This longer entry \
                name and note make wrapping, scanning, and row density easier \
                to judge before the MHUI adoption pass.
                """,
                photoData: nil,
                start: entryStart(year: 2018, precision: .year),
                createdAt: ReferenceDate.created,
                updatedAt: ReferenceDate.current,
                archivedAt: nil,
                id: uuid(Identifier.longTitle)
            )
        ]
    }

    static var archivedEntries: [Entry] {
        denseEntries.filter(\.isArchived)
    }

    static func draft(for entry: Entry) -> EntryDraft {
        guard let draft = try? EntryOperations.makeDraft(from: entry.snapshot) else {
            preconditionFailure("Preview entry draft is invalid.")
        }

        return draft
    }

    private static func entryStart(
        year: Int,
        precision: StartPrecision,
        month: Int = 1,
        day: Int = 1
    ) -> EntryStart {
        let start: EntryStart?

        switch precision {
        case .day:
            start = try? .day(
                year: year,
                month: month,
                day: day
            )
        case .month:
            start = try? .month(
                year: year,
                month: month
            )
        case .year:
            start = try? .year(year)
        }

        guard let start else {
            preconditionFailure(
                "Invalid preview entry start: \(year)-\(month)-\(day) (\(precision.rawValue))."
            )
        }

        return start
    }
}

// swiftlint:enable no_magic_numbers number_separator
