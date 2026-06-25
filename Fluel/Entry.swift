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

    func archive() {
        archive(
            archivedAt: .now,
            calendar: .autoupdatingCurrent
        )
    }

    func archive(
        archivedAt: Date,
        calendar: Calendar
    ) {
        apply(
            EntryOperations.archive(
                snapshot,
                archivedAt: archivedAt,
                calendar: calendar
            )
        )
    }

    func restore() {
        restore(
            restoredAt: .now,
            calendar: .autoupdatingCurrent
        )
    }

    func restore(
        restoredAt: Date,
        calendar: Calendar
    ) {
        apply(
            EntryOperations.restore(
                snapshot,
                restoredAt: restoredAt,
                calendar: calendar
            )
        )
    }

    private func apply(_ snapshot: EntrySnapshot) {
        title = snapshot.title
        startDate = snapshot.startDate
        startPrecision = snapshot.startPrecision
        createdAt = snapshot.createdAt
        updatedAt = snapshot.updatedAt
        archivedAt = snapshot.archivedAt
    }
}
