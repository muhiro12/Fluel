//
//  Entry.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

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

    init(
        title: String,
        startDate: Date,
        startPrecision: StartPrecision,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        archivedAt: Date? = nil,
        id: UUID = .init()
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

    func timeTogether(
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> TimeTogetherSummary {
        TimeTogetherSummary(
            startDate: startDate,
            precision: startPrecision,
            referenceDate: referenceDate,
            calendar: calendar
        )
    }
}
