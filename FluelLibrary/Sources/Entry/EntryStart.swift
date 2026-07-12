import Foundation

/// A Gregorian calendar date representing when an entry started.
///
/// Unlike `Date`, this value does not represent an absolute point in time. Its
/// year, month, and day remain stable when the user changes time zones.
public struct EntryStart: Comparable, Hashable, Sendable {
    /// Errors produced while creating or resolving an entry start.
    public enum ValidationError: Equatable, Error, Sendable {
        /// The supplied Gregorian components do not form a supported calendar date.
        case invalidDate(year: Int, month: Int, day: Int)
        /// Foundation could not convert the start to or from a date in the requested time zone.
        case dateConversionFailed(timeZoneIdentifier: String)
    }

    private static let firstDay = 1
    private static let firstMonth = 1
    private static let firstYear = 1
    private static let yearPrecisionSortOrder = 0
    private static let monthPrecisionSortOrder = 1
    private static let dayPrecisionSortOrder = 2

    /// The Gregorian year.
    public let year: Int
    /// The Gregorian month, normalized to January for year precision.
    public let month: Int
    /// The Gregorian day, normalized to the first day for month or year precision.
    public let day: Int
    /// How precisely the start is known.
    public let precision: StartPrecision

    let calculationDate: Date

    private var precisionSortOrder: Int {
        switch precision {
        case .year:
            Self.yearPrecisionSortOrder
        case .month:
            Self.monthPrecisionSortOrder
        case .day:
            Self.dayPrecisionSortOrder
        }
    }

    /// Creates a start by reading Gregorian components in an explicit time zone.
    public init(
        date: Date,
        precision: StartPrecision,
        timeZone: TimeZone
    ) throws {
        let calendar = Self.gregorianCalendar(in: timeZone)
        let components = calendar.dateComponents(
            [.year, .month, .day],
            from: date
        )

        guard let resolvedYear = components.year,
              let resolvedMonth = components.month,
              let resolvedDay = components.day else {
            throw ValidationError.dateConversionFailed(
                timeZoneIdentifier: timeZone.identifier
            )
        }

        switch precision {
        case .day:
            self = try Self.day(
                year: resolvedYear,
                month: resolvedMonth,
                day: resolvedDay
            )
        case .month:
            self = try Self.month(
                year: resolvedYear,
                month: resolvedMonth
            )
        case .year:
            self = try Self.year(resolvedYear)
        }
    }

    private init(
        validatedYear year: Int,
        month: Int,
        day: Int,
        precision: StartPrecision,
        calculationDate: Date
    ) {
        self.year = year
        self.month = month
        self.day = day
        self.precision = precision
        self.calculationDate = calculationDate
    }

    /// Creates an exact-day start from Gregorian calendar components.
    public static func day(
        year: Int,
        month: Int,
        day: Int
    ) throws -> Self {
        try validated(
            year: year,
            month: month,
            day: day,
            precision: .day
        )
    }

    /// Creates a month-precision start from Gregorian calendar components.
    public static func month(
        year: Int,
        month: Int
    ) throws -> Self {
        try validated(
            year: year,
            month: month,
            day: firstDay,
            precision: .month
        )
    }

    /// Creates a year-precision start from a Gregorian year.
    public static func year(_ year: Int) throws -> Self {
        try validated(
            year: year,
            month: firstMonth,
            day: firstDay,
            precision: .year
        )
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        }

        if lhs.month != rhs.month {
            return lhs.month < rhs.month
        }

        if lhs.day != rhs.day {
            return lhs.day < rhs.day
        }

        return lhs.precisionSortOrder < rhs.precisionSortOrder
    }

    private static func validated(
        year: Int,
        month: Int,
        day: Int,
        precision: StartPrecision
    ) throws -> Self {
        let calendar = gregorianCalendar(in: .gmt)
        let components = DateComponents(
            calendar: calendar,
            timeZone: .gmt,
            year: year,
            month: month,
            day: day
        )

        guard year >= firstYear,
              components.isValidDate(in: calendar),
              let resolvedCalculationDate = calendar.date(from: components) else {
            throw ValidationError.invalidDate(
                year: year,
                month: month,
                day: day
            )
        }

        return .init(
            validatedYear: year,
            month: month,
            day: day,
            precision: precision,
            calculationDate: resolvedCalculationDate
        )
    }

    static func gregorianCalendar(in timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    /// Resolves the calendar date to the start of that day in an explicit time zone.
    public func date(in timeZone: TimeZone) throws -> Date {
        let calendar = Self.gregorianCalendar(in: timeZone)
        let components = DateComponents(
            calendar: calendar,
            timeZone: timeZone,
            year: year,
            month: month,
            day: day
        )

        guard components.isValidDate(in: calendar),
              let date = calendar.date(from: components) else {
            throw ValidationError.dateConversionFailed(
                timeZoneIdentifier: timeZone.identifier
            )
        }

        let resolvedComponents = calendar.dateComponents(
            [.year, .month, .day],
            from: date
        )

        guard resolvedComponents.year == year,
              resolvedComponents.month == month,
              resolvedComponents.day == day else {
            throw ValidationError.dateConversionFailed(
                timeZoneIdentifier: timeZone.identifier
            )
        }

        return calendar.startOfDay(for: date)
    }
}
