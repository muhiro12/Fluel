import Foundation

/// Display-ready elapsed-time summary for an entry.
public struct TimeTogetherSummary: Equatable, Sendable {
    private struct Values {
        let primaryText: String
        let fullText: String
        let supportingText: String?
        let totalValueLabel: String?
        let totalValueText: String?
    }

    private struct DurationPart: Equatable {
        private static let singularValue = 1

        let value: Int
        let singular: String

        var isVisible: Bool {
            value > 0
        }

        var text: String {
            "\(value.formatted()) \(singular)\(value == Self.singularValue ? "" : "s")"
        }
    }

    private static let monthsPerYear = 12
    private static let primaryPartLimit = 2
    private static let approximateSupportingText = "Approximate start; based on the earliest possible start date."

    /// Compact elapsed-time text for list rows and headers.
    public let primaryText: String
    /// Full elapsed-time text for detail screens and system surfaces.
    public let fullText: String
    /// Supporting explanation for approximate starts.
    public let supportingText: String?
    /// Label for the optional total value.
    public let totalValueLabel: String?
    /// Optional total value text.
    public let totalValueText: String?

    /// Creates an elapsed-time summary from a start, precision, and reference date.
    public init(
        startDate: Date,
        precision: StartPrecision,
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        let normalizedStart = precision.normalizedStartDate(
            from: startDate,
            calendar: calendar
        )
        let normalizedReference = max(
            precision.normalizedStartDate(from: referenceDate, calendar: calendar),
            normalizedStart
        )

        switch precision {
        case .day:
            let values = Self.dayValues(
                normalizedStart: normalizedStart,
                normalizedReference: normalizedReference,
                calendar: calendar
            )
            primaryText = values.primaryText
            fullText = values.fullText
            supportingText = values.supportingText
            totalValueLabel = values.totalValueLabel
            totalValueText = values.totalValueText
        case .month:
            let values = Self.monthValues(
                normalizedStart: normalizedStart,
                normalizedReference: normalizedReference,
                calendar: calendar
            )
            primaryText = values.primaryText
            fullText = values.fullText
            supportingText = values.supportingText
            totalValueLabel = values.totalValueLabel
            totalValueText = values.totalValueText
        case .year:
            let values = Self.yearValues(
                normalizedStart: normalizedStart,
                normalizedReference: normalizedReference,
                calendar: calendar
            )
            primaryText = values.primaryText
            fullText = values.fullText
            supportingText = values.supportingText
            totalValueLabel = values.totalValueLabel
            totalValueText = values.totalValueText
        }
    }

    private static func dayValues(
        normalizedStart: Date,
        normalizedReference: Date,
        calendar: Calendar
    ) -> Values {
        let components = calendar.dateComponents(
            [.year, .month, .day],
            from: normalizedStart,
            to: normalizedReference
        )
        let totalDays = max(0, calendar.dateComponents(
            [.day],
            from: normalizedStart,
            to: normalizedReference
        ).day ?? 0)
        let durationParts = parts(
            years: components.year,
            months: components.month,
            days: components.day
        )

        return .init(
            primaryText: joined(
                durationParts,
                emptyText: "Today",
                limit: Self.primaryPartLimit
            ),
            fullText: joined(durationParts, emptyText: "Started today"),
            supportingText: nil,
            totalValueLabel: "Total days",
            totalValueText: totalDays.formatted()
        )
    }

    private static func monthValues(
        normalizedStart: Date,
        normalizedReference: Date,
        calendar: Calendar
    ) -> Values {
        let components = calendar.dateComponents(
            [.year, .month],
            from: normalizedStart,
            to: normalizedReference
        )
        let years = max(0, components.year ?? 0)
        let months = max(0, components.month ?? 0)
        let totalMonths = years * Self.monthsPerYear + months
        let durationParts = parts(years: years, months: months, days: nil)

        return .init(
            primaryText: joined(
                durationParts,
                emptyText: "This month",
                limit: Self.primaryPartLimit
            ),
            fullText: joined(durationParts, emptyText: "Started this month"),
            supportingText: approximateSupportingText,
            totalValueLabel: "Total months",
            totalValueText: totalMonths.formatted()
        )
    }

    private static func yearValues(
        normalizedStart: Date,
        normalizedReference: Date,
        calendar: Calendar
    ) -> Values {
        let years = max(0, calendar.dateComponents(
            [.year],
            from: normalizedStart,
            to: normalizedReference
        ).year ?? 0)
        let yearText = years == 0 ? "This year" : durationText(
            value: years,
            singular: "year"
        )

        return .init(
            primaryText: yearText,
            fullText: years == 0 ? "Started this year" : yearText,
            supportingText: approximateSupportingText,
            totalValueLabel: nil,
            totalValueText: nil
        )
    }

    private static func parts(
        years: Int?,
        months: Int?,
        days: Int?
    ) -> [DurationPart] {
        [
            years.map { DurationPart(value: max(0, $0), singular: "year") },
            months.map { DurationPart(value: max(0, $0), singular: "month") },
            days.map { DurationPart(value: max(0, $0), singular: "day") }
        ]
        .compactMap(\.self)
    }

    private static func joined(
        _ parts: [DurationPart],
        emptyText: String,
        limit: Int? = nil
    ) -> String {
        let visibleParts = parts.filter(\.isVisible)

        guard !visibleParts.isEmpty else {
            return emptyText
        }

        return visibleParts
            .prefix(limit ?? visibleParts.count)
            .map(\.text)
            .joined(separator: ", ")
    }

    private static func durationText(value: Int, singular: String) -> String {
        DurationPart(value: value, singular: singular).text
    }
}
