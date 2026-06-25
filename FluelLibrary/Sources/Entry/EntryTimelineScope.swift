import Foundation

/// Timeline date scope.
public enum EntryTimelineScope: String, CaseIterable, Identifiable, Sendable {
    case recentSixMonths
    case recentYear
    case allTime

    private static let recentSixMonthOffset = -6
    private static let recentYearOffset = -1

    public var id: Self {
        self
    }

    /// User-facing scope label.
    public var label: String {
        switch self {
        case .recentSixMonths:
            "Recent 6 months"
        case .recentYear:
            "Recent year"
        case .allTime:
            "All time"
        }
    }

    /// Returns the inclusive start date for this scope.
    public func startDate(
        referenceDate: Date,
        calendar: Calendar = .autoupdatingCurrent
    ) -> Date? {
        let normalizedReferenceDate = calendar.startOfDay(for: referenceDate)

        switch self {
        case .recentSixMonths:
            return calendar.date(
                byAdding: .month,
                value: Self.recentSixMonthOffset,
                to: normalizedReferenceDate
            )
        case .recentYear:
            return calendar.date(
                byAdding: .year,
                value: Self.recentYearOffset,
                to: normalizedReferenceDate
            )
        case .allTime:
            return nil
        }
    }
}
