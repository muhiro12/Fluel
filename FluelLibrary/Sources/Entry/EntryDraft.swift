import Foundation

/// Editable entry draft values shared by UI and future system surfaces.
public struct EntryDraft: Equatable, Sendable {
    private static let earliestYear = 1_900
    private static let firstMonth = 1
    private static let lastMonth = 12

    /// Raw title text.
    public var title: String
    /// Raw note text.
    public var note: String
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

    /// Trimmed note text.
    public var trimmedNote: String {
        note.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// True when the draft can be saved.
    public var canSave: Bool {
        !trimmedTitle.isEmpty
    }

    /// True when dismissing the draft would lose user-entered content.
    public var hasUnsavedContent: Bool {
        !trimmedTitle.isEmpty || !trimmedNote.isEmpty || precision != .day
    }

    /// Creates an editable entry draft.
    public init(
        title: String = "",
        note: String = "",
        precision: StartPrecision = .day,
        dayDate: Date = Date(),
        month: Int? = nil,
        year: Int? = nil,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        let gregorianCalendar = EntryStart.gregorianCalendar(in: calendar.timeZone)
        let components = gregorianCalendar.dateComponents(
            [.year, .month],
            from: dayDate
        )

        self.title = title
        self.note = note
        self.precision = precision
        self.dayDate = dayDate
        self.month = month ?? components.month ?? Self.firstMonth
        self.year = year ?? components.year ?? Self.earliestYear
    }

    /// Returns selectable years up to the current year.
    public func availableYears(
        currentDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> [Int] {
        let gregorianCalendar = EntryStart.gregorianCalendar(in: calendar.timeZone)
        let currentYear = gregorianCalendar.component(.year, from: currentDate)

        guard currentYear >= Self.earliestYear else {
            return [currentYear]
        }

        return Array(Self.earliestYear...currentYear).reversed()
    }

    /// Returns selectable months, clamped when the selected year is current.
    public func availableMonths(
        currentDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> [Int] {
        let gregorianCalendar = EntryStart.gregorianCalendar(in: calendar.timeZone)
        let currentYear = gregorianCalendar.component(.year, from: currentDate)

        guard year == currentYear else {
            return Array(Self.firstMonth...Self.lastMonth)
        }

        return Array(Self.firstMonth...gregorianCalendar.component(.month, from: currentDate))
    }

    /// Resolves the draft into a validated calendar start.
    public func start(calendar: Calendar = .autoupdatingCurrent) throws -> EntryStart {
        switch precision {
        case .day:
            try EntryStart(
                date: dayDate,
                precision: precision,
                timeZone: calendar.timeZone
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

    /// Formats the draft start for display.
    public func startLabel(calendar: Calendar = .autoupdatingCurrent) throws -> String {
        let start = try start(calendar: calendar)

        return precision.startLabel(
            for: start,
            calendar: calendar
        )
    }

    /// Creates validated entry input.
    public func makeInput(
        currentDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) throws -> EntryInput {
        try EntryInput(
            title: trimmedTitle,
            start: start(calendar: calendar),
            note: trimmedNote,
            currentDate: currentDate,
            calendar: calendar
        )
    }

    /// Aligns month and year components with the exact-day date.
    public mutating func alignComponentsWithPrecision(
        calendar: Calendar = .autoupdatingCurrent
    ) {
        let gregorianCalendar = EntryStart.gregorianCalendar(in: calendar.timeZone)
        let components = gregorianCalendar.dateComponents([.year, .month], from: dayDate)
        year = components.year ?? year
        month = components.month ?? month
        clampToPresent(calendar: calendar)
    }

    /// Clamps approximate start values so they cannot point into the future.
    public mutating func clampToPresent(
        currentDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        let gregorianCalendar = EntryStart.gregorianCalendar(in: calendar.timeZone)
        let currentYear = gregorianCalendar.component(.year, from: currentDate)
        let currentMonth = gregorianCalendar.component(.month, from: currentDate)

        year = min(max(year, Self.earliestYear), currentYear)

        if year == currentYear {
            month = min(month, currentMonth)
        }

        month = min(max(month, Self.firstMonth), Self.lastMonth)
    }
}
