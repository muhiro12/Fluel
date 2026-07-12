import Foundation

/// Relative start used by a preset.
public enum EntryPresetStart: Equatable, Sendable {
    case today
    case monthsAgo(Int)
    case yearsAgo(Int)

    /// Resolves the relative start to a date.
    public func date(
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> Date {
        let gregorianCalendar = EntryStart.gregorianCalendar(in: calendar.timeZone)

        switch self {
        case .today:
            return gregorianCalendar.startOfDay(for: referenceDate)
        case .monthsAgo(let value):
            return gregorianCalendar.date(
                byAdding: .month,
                value: -max(0, value),
                to: referenceDate
            )
            .map { date in
                gregorianCalendar.startOfDay(for: date)
            } ?? gregorianCalendar.startOfDay(for: referenceDate)
        case .yearsAgo(let value):
            return gregorianCalendar.date(
                byAdding: .year,
                value: -max(0, value),
                to: referenceDate
            )
            .map { date in
                gregorianCalendar.startOfDay(for: date)
            } ?? gregorianCalendar.startOfDay(for: referenceDate)
        }
    }
}
