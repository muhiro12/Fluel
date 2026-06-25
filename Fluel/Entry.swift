//
//  Entry.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import Foundation
import SwiftData

@Model
final class Entry {
    @Attribute(.unique)
    var id: UUID
    var title: String
    var startDate: Date
    var startPrecision: StartPrecision
    var createdAt: Date
    var updatedAt: Date
    var archivedAt: Date?

    var isArchived: Bool {
        archivedAt != nil
    }

    var snapshot: EntrySnapshot {
        .init(
            id: id,
            title: title,
            startDate: startDate,
            startPrecision: startPrecision,
            createdAt: createdAt,
            updatedAt: updatedAt,
            archivedAt: archivedAt
        )
    }

    init(
        title: String,
        startDate: Date,
        startPrecision: StartPrecision,
        createdAt: Date,
        updatedAt: Date,
        archivedAt: Date?,
        id: UUID
    ) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        precondition(!trimmedTitle.isEmpty, "Entry titles must not be empty.")

        self.id = id
        self.title = trimmedTitle
        self.startDate = startPrecision.normalizedStartDate(from: startDate)
        self.startPrecision = startPrecision
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.archivedAt = archivedAt
    }

    convenience init(
        title: String,
        startDate: Date,
        startPrecision: StartPrecision,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.init(
            title: title,
            startDate: startDate,
            startPrecision: startPrecision,
            createdAt: createdAt,
            updatedAt: updatedAt,
            archivedAt: nil,
            id: .init()
        )
    }

    convenience init(input: EntryInput) {
        self.init(
            input: input,
            createdAt: .now,
            updatedAt: .now,
            archivedAt: nil,
            id: .init()
        )
    }

    convenience init(
        input: EntryInput,
        createdAt: Date,
        updatedAt: Date,
        archivedAt: Date?,
        id: UUID
    ) {
        self.init(
            title: input.title,
            startDate: input.startDate,
            startPrecision: input.startPrecision,
            createdAt: createdAt,
            updatedAt: updatedAt,
            archivedAt: archivedAt,
            id: id
        )
    }

    func timeTogether() -> TimeTogetherSummary {
        timeTogether(
            referenceDate: .now,
            calendar: .autoupdatingCurrent
        )
    }

    func timeTogether(
        referenceDate: Date,
        calendar: Calendar
    ) -> TimeTogetherSummary {
        EntryOperations.timeTogether(
            for: snapshot,
            referenceDate: referenceDate,
            calendar: calendar
        )
    }
}
