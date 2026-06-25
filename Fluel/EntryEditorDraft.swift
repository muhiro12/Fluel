//
//  EntryEditorDraft.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import Foundation

struct EntryEditorDraft: Equatable {
    private static let earliestYear = 1_900
    private static let firstDay = 1
    private static let firstMonth = 1
    private static let lastMonth = 12

    var title = ""
    var precision: StartPrecision = .day
    var dayDate = Date()
    var month = Calendar.autoupdatingCurrent.component(.month, from: .now)
    var year = Calendar.autoupdatingCurrent.component(.year, from: .now)

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool {
        !trimmedTitle.isEmpty
    }

    var hasUnsavedContent: Bool {
        !trimmedTitle.isEmpty || precision != .day
    }

    func availableYears(
        currentDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> [Int] {
        let currentYear = calendar.component(.year, from: currentDate)

        return Array(Self.earliestYear...currentYear).reversed()
    }

    func availableMonths(
        currentDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> [Int] {
        let currentYear = calendar.component(.year, from: currentDate)

        guard year == currentYear else {
            return Array(Self.firstMonth...Self.lastMonth)
        }

        return Array(Self.firstMonth...calendar.component(.month, from: currentDate))
    }

    func startDate(calendar: Calendar = .autoupdatingCurrent) -> Date {
        switch precision {
        case .day:
            precision.normalizedStartDate(from: dayDate, calendar: calendar)
        case .month:
            calendar.date(from: DateComponents(
                calendar: calendar,
                year: year,
                month: month,
                day: 1
            )) ?? precision.normalizedStartDate(from: dayDate, calendar: calendar)
        case .year:
            calendar.date(from: DateComponents(
                calendar: calendar,
                year: year,
                month: Self.firstMonth,
                day: Self.firstDay
            )) ?? precision.normalizedStartDate(from: dayDate, calendar: calendar)
        }
    }

    func startLabel(calendar: Calendar = .autoupdatingCurrent) -> String {
        precision.startLabel(
            for: startDate(calendar: calendar),
            calendar: calendar
        )
    }

    func makeEntry(calendar: Calendar = .autoupdatingCurrent) -> Entry {
        Entry(
            title: trimmedTitle,
            startDate: startDate(calendar: calendar),
            startPrecision: precision
        )
    }

    mutating func alignComponentsWithPrecision(
        calendar: Calendar = .autoupdatingCurrent
    ) {
        let components = calendar.dateComponents([.year, .month], from: dayDate)
        year = components.year ?? year
        month = components.month ?? month
        clampToPresent(calendar: calendar)
    }

    mutating func clampToPresent(
        currentDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)

        year = min(max(year, Self.earliestYear), currentYear)

        if year == currentYear {
            month = min(month, currentMonth)
        }

        month = min(max(month, Self.firstMonth), Self.lastMonth)
    }
}
