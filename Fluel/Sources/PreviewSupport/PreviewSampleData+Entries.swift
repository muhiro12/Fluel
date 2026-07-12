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
        let encodedPhoto = "iVBORw0KGgoAAAANSUhEUgAAAAgAAAAGCAYAAAD+Bd/7AAAAAXNSR0IArs4c6QAA"
            + "ADhlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAAqACAAQAAAABAAAACKAD"
            + "AAQAAAABAAAABgAAAAAJfOcJAAAATklEQVQIHWMUnbv0PwMewASTsxdmZDhqwwzG"
            + "IDYMwBW0aTIxSHIwgjGIDQMIFkwEjYYrqLr+j+H5j/9gDGLDAAuMcfDtfwbrI39"
            + "hXDgNAIWhFbt9COKBAAAAAElFTkSuQmCC"

        guard let data = Data(
            base64Encoded: encodedPhoto
        ) else {
            preconditionFailure("Preview photo fixture is invalid.")
        }

        return data
    }

    static var sampleEntries: [Entry] {
        typicalEntries
    }

    static var typicalEntries: [Entry] {
        [
            Entry(
                title: "This home",
                note: "A home is where daily life gathers.",
                photoData: nil,
                start: entryStart(year: 2021, precision: .year),
                createdAt: ReferenceDate.created,
                updatedAt: ReferenceDate.created,
                archivedAt: nil,
                id: uuid(Identifier.thisHome)
            ),
            Entry(
                title: "Notebook",
                note: "Ordinary thoughts from this year.",
                photoData: nil,
                start: entryStart(year: 2024, precision: .month, month: 9),
                createdAt: ReferenceDate.created,
                updatedAt: ReferenceDate.created,
                archivedAt: nil,
                id: uuid(Identifier.notebook)
            ),
            Entry(
                title: "Watch",
                note: nil,
                photoData: samplePhotoData,
                start: entryStart(year: 2025, precision: .day, month: 12, day: 14),
                createdAt: ReferenceDate.created,
                updatedAt: ReferenceDate.created,
                archivedAt: nil,
                id: uuid(Identifier.watch)
            ),
            Entry(
                title: "Desk lamp",
                note: "Moved to storage.",
                photoData: nil,
                start: entryStart(year: 2023, precision: .day, month: 2, day: 14),
                createdAt: ReferenceDate.created,
                updatedAt: ReferenceDate.current,
                archivedAt: ReferenceDate.current,
                id: uuid(Identifier.deskLamp)
            )
        ]
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
