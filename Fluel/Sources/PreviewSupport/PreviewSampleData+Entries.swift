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
    static var sampleEntries: [Entry] {
        typicalEntries
    }

    static var typicalEntries: [Entry] {
        [
            Entry(
                title: "This home",
                note: "A home is where daily life gathers.",
                photoData: nil,
                startDate: date(year: 2021, month: 4, day: 1),
                startPrecision: .year,
                createdAt: ReferenceDate.created,
                updatedAt: ReferenceDate.created,
                archivedAt: nil,
                id: uuid(Identifier.thisHome)
            ),
            Entry(
                title: "Notebook",
                note: "Ordinary thoughts from this year.",
                photoData: nil,
                startDate: date(year: 2024, month: 9, day: 1),
                startPrecision: .month,
                createdAt: ReferenceDate.created,
                updatedAt: ReferenceDate.created,
                archivedAt: nil,
                id: uuid(Identifier.notebook)
            ),
            Entry(
                title: "Watch",
                note: nil,
                photoData: Data([1]),
                startDate: date(year: 2025, month: 12, day: 14),
                startPrecision: .day,
                createdAt: ReferenceDate.created,
                updatedAt: ReferenceDate.created,
                archivedAt: nil,
                id: uuid(Identifier.watch)
            ),
            Entry(
                title: "Desk lamp",
                note: "Moved to storage.",
                photoData: nil,
                startDate: date(year: 2023, month: 2, day: 14),
                startPrecision: .day,
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
                photoData: Data([1]),
                startDate: date(year: 2020, month: 1, day: 1),
                startPrecision: .year,
                createdAt: ReferenceDate.created,
                updatedAt: ReferenceDate.current,
                archivedAt: nil,
                id: uuid(Identifier.wallet)
            ),
            Entry(
                title: "Bag",
                note: nil,
                photoData: nil,
                startDate: date(year: 2024, month: 11, day: 1),
                startPrecision: .month,
                createdAt: ReferenceDate.created,
                updatedAt: ReferenceDate.current,
                archivedAt: nil,
                id: uuid(Identifier.bag)
            ),
            Entry(
                title: "Plant",
                note: "Shares the same light near the kitchen window.",
                photoData: nil,
                startDate: date(year: 2024, month: 3, day: 1),
                startPrecision: .month,
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
                startDate: date(year: 2018, month: 1, day: 1),
                startPrecision: .year,
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
}

// swiftlint:enable no_magic_numbers number_separator
