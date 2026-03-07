import Foundation

/// Precision-aware elapsed time snapshot derived from one entry start date.
public struct EntryElapsedSnapshot: Equatable, Sendable {
    public let precision: EntryDatePrecision
    public let years: Int
    public let months: Int
    public let days: Int
    public let totalMonths: Int?
    public let totalDays: Int?

    public init(
        startComponents: EntryStartComponents,
        referenceDate: Date,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        precision = startComponents.precision

        switch startComponents.precision {
        case .day:
            let startDate = calendar.startOfDay(
                for: startComponents.earliestDate(calendar: calendar) ?? referenceDate
            )
            let referenceStartOfDay = calendar.startOfDay(for: referenceDate)
            let clampedReferenceDate = max(referenceStartOfDay, startDate)
            let elapsedComponents = calendar.dateComponents(
                [.year, .month, .day],
                from: startDate,
                to: clampedReferenceDate
            )

            years = max(elapsedComponents.year ?? 0, 0)
            months = max(elapsedComponents.month ?? 0, 0)
            days = max(elapsedComponents.day ?? 0, 0)
            totalMonths = nil
            totalDays = max(
                calendar.dateComponents(
                    [.day],
                    from: startDate,
                    to: clampedReferenceDate
                ).day ?? 0,
                0
            )
        case .month:
            let referenceYear = calendar.component(.year, from: referenceDate)
            let referenceMonth = calendar.component(.month, from: referenceDate)
            let startMonth = startComponents.month ?? 1
            let rawTotalMonths = ((referenceYear - startComponents.year) * 12) + (referenceMonth - startMonth)
            let totalMonths = max(rawTotalMonths, 0)

            years = totalMonths / 12
            months = totalMonths % 12
            days = 0
            self.totalMonths = totalMonths
            totalDays = nil
        case .year:
            let referenceYear = calendar.component(.year, from: referenceDate)

            years = max(referenceYear - startComponents.year, 0)
            months = 0
            days = 0
            totalMonths = nil
            totalDays = nil
        }
    }
}
