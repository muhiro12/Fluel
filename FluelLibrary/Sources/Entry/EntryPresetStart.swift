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
        switch self {
        case .today:
            calendar.startOfDay(for: referenceDate)
        case .monthsAgo(let value):
            calendar.date(byAdding: .month, value: -max(0, value), to: referenceDate)
                .map { date in
                    calendar.startOfDay(for: date)
                } ?? calendar.startOfDay(for: referenceDate)
        case .yearsAgo(let value):
            calendar.date(byAdding: .year, value: -max(0, value), to: referenceDate)
                .map { date in
                    calendar.startOfDay(for: date)
                } ?? calendar.startOfDay(for: referenceDate)
        }
    }
}
