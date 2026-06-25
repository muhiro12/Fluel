import Foundation

/// The known precision of an entry's start.
public enum StartPrecision: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case day
    case month
    case year

    private static let monthNameReferenceYear = 2_024

    public var id: Self {
        self
    }

    /// Short label for picker and compact presentation.
    public var label: String {
        switch self {
        case .day:
            "Day"
        case .month:
            "Month"
        case .year:
            "Year"
        }
    }

    /// Describes how much of the start is known.
    public var knownAsText: String {
        switch self {
        case .day:
            "Exact day"
        case .month:
            "Known to the month"
        case .year:
            "Known to the year"
        }
    }

    /// True when the start represents a range instead of an exact day.
    public var isApproximate: Bool {
        self != .day
    }

    /// Returns a localized month name for picker presentation.
    public static func monthName(
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

    /// Normalizes a date to the earliest date represented by this precision.
    public func normalizedStartDate(
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

    /// Formats the known start value for display.
    public func startLabel(
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

    /// Formats the approximate range represented by a month or year start.
    public func startRangeLabel(
        for date: Date,
        calendar: Calendar = .autoupdatingCurrent
    ) -> String? {
        let normalizedDate = normalizedStartDate(from: date, calendar: calendar)

        switch self {
        case .day:
            return nil
        case .month:
            return dateRangeLabel(component: .month, normalizedDate: normalizedDate, calendar: calendar)
        case .year:
            return dateRangeLabel(component: .year, normalizedDate: normalizedDate, calendar: calendar)
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

    private func dateRangeLabel(
        component: Calendar.Component,
        normalizedDate: Date,
        calendar: Calendar
    ) -> String? {
        guard let interval = calendar.dateInterval(of: component, for: normalizedDate),
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
