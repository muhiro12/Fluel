import Foundation

/// Precision-aware start date components persisted for one entry.
public struct EntryStartComponents: Equatable, Hashable, Codable, Sendable {
    public let precision: EntryDatePrecision
    public let year: Int
    public let month: Int?
    public let day: Int?

    public init(
        precision: EntryDatePrecision,
        year: Int,
        month: Int? = nil,
        day: Int? = nil
    ) throws {
        let validationCalendar = Calendar(identifier: .gregorian)

        guard 1...9_999 ~= year else { // swiftlint:disable:this no_magic_numbers
            throw EntryRepositoryError.invalidStartDate
        }

        switch precision {
        case .day:
            guard let month,
                  let day,
                  1...12 ~= month else { // swiftlint:disable:this no_magic_numbers
                throw EntryRepositoryError.invalidStartDate
            }

            let components = DateComponents(
                calendar: validationCalendar,
                year: year,
                month: month,
                day: day
            )

            guard validationCalendar.date(from: components) != nil else {
                throw EntryRepositoryError.invalidStartDate
            }

            self.month = month
            self.day = day
        case .month:
            guard let month,
                  1...12 ~= month, // swiftlint:disable:this no_magic_numbers
                  day == nil else {
                throw EntryRepositoryError.invalidStartDate
            }

            self.month = month
            self.day = nil
        case .year:
            guard month == nil,
                  day == nil else {
                throw EntryRepositoryError.invalidStartDate
            }

            self.month = nil
            self.day = nil
        }

        self.precision = precision
        self.year = year
    }

    public func earliestDate(
        calendar: Calendar = .autoupdatingCurrent
    ) -> Date? {
        let month = month ?? 1
        let day = day ?? 1

        return calendar.date(
            from: .init(
                year: year,
                month: month,
                day: day
            )
        )
    }

    public func isInFuture(
        referenceDate: Date,
        calendar: Calendar = .autoupdatingCurrent
    ) -> Bool {
        let referenceStartOfDay = calendar.startOfDay(for: referenceDate)
        let referenceYear = calendar.component(.year, from: referenceStartOfDay)
        let referenceMonth = calendar.component(.month, from: referenceStartOfDay)

        switch precision {
        case .day:
            guard let startDate = earliestDate(calendar: calendar) else {
                return true
            }

            return calendar.startOfDay(for: startDate) > referenceStartOfDay
        case .month:
            guard let month else {
                return true
            }

            let startValue = year * 100 + month
            let referenceValue = referenceYear * 100 + referenceMonth

            return startValue > referenceValue
        case .year:
            return year > referenceYear
        }
    }
}
