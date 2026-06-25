//
//  StartPrecision.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import Foundation

enum StartPrecision: String, CaseIterable, Codable, Identifiable {
    case day
    case month
    case year

    private static let monthNameReferenceYear = 2_024

    var id: Self {
        self
    }

    var label: String {
        switch self {
        case .day:
            "Day"
        case .month:
            "Month"
        case .year:
            "Year"
        }
    }

    var knownAsText: String {
        switch self {
        case .day:
            "Exact day"
        case .month:
            "Known to the month"
        case .year:
            "Known to the year"
        }
    }

    var isApproximate: Bool {
        self != .day
    }

    static func monthName(
        for month: Int,
        calendar: Calendar = .autoupdatingCurrent
    ) -> String {
        var components = DateComponents()
        components.calendar = calendar
        components.year = Self.monthNameReferenceYear
        components.month = month
        components.day = 1

        guard let date = components.date else {
            return String(month)
        }

        return date.formatted(.dateTime.month(.wide))
    }

    func normalizedStartDate(
        from date: Date,
        calendar: Calendar = .autoupdatingCurrent
    ) -> Date {
        switch self {
        case .day:
            calendar.startOfDay(for: date)
        case .month:
            normalizedDate(
                from: date,
                components: [.year, .month],
                calendar: calendar
            )
        case .year:
            normalizedDate(
                from: date,
                components: [.year],
                calendar: calendar
            )
        }
    }

    func startLabel(
        for date: Date,
        calendar: Calendar = .autoupdatingCurrent
    ) -> String {
        let normalizedDate = normalizedStartDate(from: date, calendar: calendar)

        switch self {
        case .day:
            return normalizedDate.formatted(date: .abbreviated, time: .omitted)
        case .month:
            return normalizedDate.formatted(.dateTime.month(.wide).year())
        case .year:
            return String(calendar.component(.year, from: normalizedDate))
        }
    }

    func startRangeLabel(
        for date: Date,
        calendar: Calendar = .autoupdatingCurrent
    ) -> String? {
        let normalizedDate = normalizedStartDate(from: date, calendar: calendar)

        switch self {
        case .day:
            return nil
        case .month:
            guard let interval = calendar.dateInterval(of: .month, for: normalizedDate),
                  let finalDay = calendar.date(byAdding: .day, value: -1, to: interval.end) else {
                return nil
            }

            return [
                interval.start.formatted(date: .abbreviated, time: .omitted),
                finalDay.formatted(date: .abbreviated, time: .omitted)
            ]
            .joined(separator: " - ")
        case .year:
            guard let interval = calendar.dateInterval(of: .year, for: normalizedDate),
                  let finalDay = calendar.date(byAdding: .day, value: -1, to: interval.end) else {
                return nil
            }

            return [
                interval.start.formatted(date: .abbreviated, time: .omitted),
                finalDay.formatted(date: .abbreviated, time: .omitted)
            ]
            .joined(separator: " - ")
        }
    }

    private func normalizedDate(
        from date: Date,
        components: Set<Calendar.Component>,
        calendar: Calendar
    ) -> Date {
        let dateComponents = calendar.dateComponents(components, from: date)

        return calendar.date(from: DateComponents(
            calendar: calendar,
            year: dateComponents.year,
            month: dateComponents.month ?? 1,
            day: 1
        )) ?? calendar.startOfDay(for: date)
    }
}
