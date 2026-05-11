import FluelLibrary
import Foundation

enum EntryPresetFormatting {
    static func startText(
        for definition: EntryPresetDefinition,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        switch definition.startPrecision {
        case .day:
            if definition.relativeValue == 0 {
                return FluelCopy.startedToday(locale: locale)
            }

            return FluelCopy.startedDaysAgo(
                definition.relativeValue,
                locale: locale
            )
        case .month:
            if definition.relativeValue == 0 {
                return FluelCopy.startedThisMonth(locale: locale)
            }

            return FluelCopy.startedMonthsAgo(
                definition.relativeValue,
                locale: locale
            )
        case .year:
            if definition.relativeValue == 0 {
                return FluelCopy.startedThisYear(locale: locale)
            }

            return FluelCopy.startedYearsAgo(
                definition.relativeValue,
                locale: locale
            )
        }
    }

    static func detailText(
        for preset: EntryPreset,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let precision = EntryFormatting.precisionText(
            for: preset.startPrecision,
            locale: locale
        )
        let start = startText(
            for: preset.definition,
            locale: locale
        )

        return "\(start) · \(precision)"
    }
}

extension EntryPresetDefinition {
    func resolvedInput(
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> EntryFormInput {
        let adjustedDate = calendar.date(
            byAdding: relativeCalendarComponent,
            value: -relativeValue,
            to: referenceDate
        ) ?? referenceDate

        switch startPrecision {
        case .day:
            return .init(
                title: trimmedTitle,
                startPrecision: .day,
                startYear: calendar.component(.year, from: adjustedDate),
                startMonth: calendar.component(.month, from: adjustedDate),
                startDay: calendar.component(.day, from: adjustedDate),
                note: normalizedNote
            )
        case .month:
            return .init(
                title: trimmedTitle,
                startPrecision: .month,
                startYear: calendar.component(.year, from: adjustedDate),
                startMonth: calendar.component(.month, from: adjustedDate),
                note: normalizedNote
            )
        case .year:
            return .init(
                title: trimmedTitle,
                startPrecision: .year,
                startYear: calendar.component(.year, from: adjustedDate),
                note: normalizedNote
            )
        }
    }

    private var relativeCalendarComponent: Calendar.Component {
        switch startPrecision {
        case .day:
            return .day
        case .month:
            return .month
        case .year:
            return .year
        }
    }
}
