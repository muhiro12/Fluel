import Foundation

/// Editable entry draft values shared by UI and future system surfaces.
public struct EntryDraft: Equatable, Sendable {
    private static let earliestYear = 1_900
    private static let firstDay = 1
    private static let firstMonth = 1
    private static let lastMonth = 12

    /// Raw title text.
    public var title: String
    /// Selected start precision.
    public var precision: StartPrecision
    /// Exact-day date value.
    public var dayDate: Date
    /// Approximate month value.
    public var month: Int
    /// Approximate year value.
    public var year: Int

    /// Trimmed title text.
    public var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// True when the draft can be saved.
    public var canSave: Bool {
        !trimmedTitle.isEmpty
    }

    /// True when dismissing the draft would lose user-entered content.
    public var hasUnsavedContent: Bool {
        !trimmedTitle.isEmpty || precision != .day
    }

    /// Creates an editable entry draft.
    public init(
        title: String = "",
        precision: StartPrecision = .day,
        dayDate: Date = Date(),
        month: Int? = nil,
        year: Int? = nil,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        let currentDate = Date()

        self.title = title
        self.precision = precision
        self.dayDate = dayDate
        self.month = month ?? calendar.component(.month, from: currentDate)
        self.year = year ?? calendar.component(.year, from: currentDate)
    }

    /// Returns selectable years up to the current year.
    public func availableYears(
        currentDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> [Int] {
        let currentYear = calendar.component(.year, from: currentDate)

        return Array(Self.earliestYear...currentYear).reversed()
    }

    /// Returns selectable months, clamped when the selected year is current.
    public func availableMonths(
        currentDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> [Int] {
        let currentYear = calendar.component(.year, from: currentDate)

        guard year == currentYear else {
            return Array(Self.firstMonth...Self.lastMonth)
        }

        return Array(Self.firstMonth...calendar.component(.month, from: currentDate))
    }

    /// Resolves the draft into the earliest start date represented by the precision.
    public func startDate(calendar: Calendar = .autoupdatingCurrent) -> Date {
        switch precision {
        case .day:
            precision.normalizedStartDate(from: dayDate, calendar: calendar)
        case .month:
            calendar.date(from: DateComponents(
                calendar: calendar,
                year: year,
                month: month,
                day: Self.firstDay
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

    /// Formats the draft start for display.
    public func startLabel(calendar: Calendar = .autoupdatingCurrent) -> String {
        precision.startLabel(
            for: startDate(calendar: calendar),
            calendar: calendar
        )
    }

    /// Creates validated entry input.
    public func makeInput(calendar: Calendar = .autoupdatingCurrent) throws -> EntryInput {
        try EntryInput(
            title: trimmedTitle,
            startDate: startDate(calendar: calendar),
            startPrecision: precision,
            calendar: calendar
        )
    }

    /// Aligns month and year components with the exact-day date.
    public mutating func alignComponentsWithPrecision(
        calendar: Calendar = .autoupdatingCurrent
    ) {
        let components = calendar.dateComponents([.year, .month], from: dayDate)
        year = components.year ?? year
        month = components.month ?? month
        clampToPresent(calendar: calendar)
    }

    /// Clamps approximate start values so they cannot point into the future.
    public mutating func clampToPresent(
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
