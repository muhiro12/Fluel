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
            EntryLocalization.string("Day")
        case .month:
            EntryLocalization.string("Month")
        case .year:
            EntryLocalization.string("Year")
        }
    }

    /// Describes how much of the start is known.
    public var knownAsText: String {
        switch self {
        case .day:
            EntryLocalization.string("Exact day")
        case .month:
            EntryLocalization.string("Known to the month")
        case .year:
            EntryLocalization.string("Known to the year")
        }
    }

    /// True when the start represents a range instead of an exact day.
    public var isApproximate: Bool {
        self != .day
    }

    /// Returns a localized Gregorian month name for picker presentation.
    public static func monthName(
        for month: Int,
        calendar: Calendar = .autoupdatingCurrent
    ) -> String {
        guard let start = try? EntryStart.month(
            year: monthNameReferenceYear,
            month: month
        ) else {
            return String(month)
        }

        return formattedDate(
            start.calculationDate,
            template: "MMMM",
            calendar: calendar
        )
    }

    private static func dateRangeLabel(
        component: Calendar.Component,
        start: EntryStart,
        calendar: Calendar
    ) -> String? {
        let calculationCalendar = EntryStart.gregorianCalendar(in: .gmt)

        guard let interval = calculationCalendar.dateInterval(
            of: component,
            for: start.calculationDate
        ),
        let finalDay = calculationCalendar.date(
            byAdding: .day,
            value: -1,
            to: interval.end
        ) else {
            return nil
        }

        return [
            formattedDate(interval.start, template: "yMMMd", calendar: calendar),
            formattedDate(finalDay, template: "yMMMd", calendar: calendar)
        ]
        .joined(separator: " - ")
    }

    private static func formattedDate(
        _ date: Date,
        template: String,
        calendar: Calendar
    ) -> String {
        let formatter = DateFormatter()
        formatter.calendar = EntryStart.gregorianCalendar(in: .gmt)
        formatter.locale = calendar.locale ?? .autoupdatingCurrent
        formatter.timeZone = .gmt
        formatter.setLocalizedDateFormatFromTemplate(template)

        return formatter.string(from: date)
    }

    /// Formats a Gregorian entry start for display.
    public func startLabel(
        for start: EntryStart,
        calendar: Calendar = .autoupdatingCurrent
    ) -> String {
        switch self {
        case .day:
            Self.formattedDate(
                start.calculationDate,
                template: "yMMMd",
                calendar: calendar
            )
        case .month:
            Self.formattedDate(
                start.calculationDate,
                template: "yMMMM",
                calendar: calendar
            )
        case .year:
            String(start.year)
        }
    }

    /// Formats the approximate Gregorian range represented by a month or year start.
    public func startRangeLabel(
        for start: EntryStart,
        calendar: Calendar = .autoupdatingCurrent
    ) -> String? {
        switch self {
        case .day:
            nil
        case .month:
            Self.dateRangeLabel(
                component: .month,
                start: start,
                calendar: calendar
            )
        case .year:
            Self.dateRangeLabel(
                component: .year,
                start: start,
                calendar: calendar
            )
        }
    }
}
