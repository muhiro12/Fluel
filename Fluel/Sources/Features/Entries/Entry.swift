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
    private static let defaultStartYear = 1_970

    var id = UUID()
    var title = ""
    var note: String?
    @Attribute(.externalStorage)
    var photoData: Data?
    var startYear = defaultStartYear
    var startMonth = 1
    var startDay = 1
    var startPrecision = StartPrecision.day
    var createdAt = Date()
    var updatedAt = Date()
    var archivedAt: Date?

    var start: EntryStart {
        guard let resolvedStart = try? Self.makeStart(
            year: startYear,
            month: startMonth,
            day: startDay,
            precision: startPrecision
        ) else {
            preconditionFailure(
                "Entry contains an invalid start: \(startYear)-\(startMonth)-\(startDay) "
                    + "(\(startPrecision.rawValue))."
            )
        }

        return resolvedStart
    }

    var isArchived: Bool {
        archivedAt != nil
    }

    var hasNote: Bool {
        normalizedNote != nil
    }

    var hasPhoto: Bool {
        photoData != nil
    }

    var snapshot: EntrySnapshot {
        .init(
            id: id,
            title: title,
            start: start,
            createdAt: createdAt,
            updatedAt: updatedAt,
            archivedAt: archivedAt,
            note: normalizedNote,
            hasPhoto: hasPhoto
        )
    }

    private var normalizedNote: String? {
        Self.normalizedNote(note)
    }

    init(
        title: String,
        note: String?,
        photoData: Data?,
        start: EntryStart,
        createdAt: Date,
        updatedAt: Date,
        archivedAt: Date?,
        id: UUID
    ) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        precondition(!trimmedTitle.isEmpty, "Entry titles must not be empty.")

        self.id = id
        self.title = trimmedTitle
        self.note = Self.normalizedNote(note)
        self.photoData = photoData
        startYear = start.year
        startMonth = start.month
        startDay = start.day
        startPrecision = start.precision
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.archivedAt = archivedAt
    }

    convenience init(
        title: String,
        note: String?,
        photoData: Data?,
        start: EntryStart,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.init(
            title: title,
            note: note,
            photoData: photoData,
            start: start,
            createdAt: createdAt,
            updatedAt: updatedAt,
            archivedAt: nil,
            id: .init()
        )
    }

    convenience init(input: EntryInput) {
        let currentDate = Date()

        self.init(
            input: input,
            photoData: nil,
            createdAt: currentDate,
            updatedAt: currentDate,
            archivedAt: nil,
            id: .init()
        )
    }

    convenience init(
        input: EntryInput,
        photoData: Data?,
        createdAt: Date,
        updatedAt: Date,
        archivedAt: Date?,
        id: UUID
    ) {
        self.init(
            title: input.title,
            note: input.note,
            photoData: photoData,
            start: input.start,
            createdAt: createdAt,
            updatedAt: updatedAt,
            archivedAt: archivedAt,
            id: id
        )
    }

    private static func normalizedNote(_ note: String?) -> String? {
        let trimmedNote = note?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let trimmedNote,
              !trimmedNote.isEmpty else {
            return nil
        }

        return trimmedNote
    }

    private static func makeStart(
        year: Int,
        month: Int,
        day: Int,
        precision: StartPrecision
    ) throws -> EntryStart {
        switch precision {
        case .day:
            try EntryStart.day(
                year: year,
                month: month,
                day: day
            )
        case .month:
            try EntryStart.month(
                year: year,
                month: month
            )
        case .year:
            try EntryStart.year(year)
        }
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

    func apply(_ snapshot: EntrySnapshot) {
        title = snapshot.title
        note = snapshot.note
        startYear = snapshot.start.year
        startMonth = snapshot.start.month
        startDay = snapshot.start.day
        startPrecision = snapshot.start.precision
        createdAt = snapshot.createdAt
        updatedAt = snapshot.updatedAt
        archivedAt = snapshot.archivedAt
    }
}
