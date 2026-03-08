import Foundation

/// Shared display formatting for entry dates and elapsed time.
public enum EntryFormatting {
    public static func primaryElapsedText(
        for snapshot: EntryElapsedSnapshot,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let language = FluelLocale(locale: locale)

        switch snapshot.precision {
        case .day:
            guard let totalDays = snapshot.totalDays,
                  totalDays > 0 else {
                return localized(
                    english: "Today",
                    japanese: "今日",
                    locale: locale
                )
            }

            if snapshot.years > 0 {
                return language.join(
                    [
                        language.yearUnit(snapshot.years, locale: locale),
                        snapshot.months > 0
                            ? language.monthUnit(snapshot.months, locale: locale)
                            : nil
                    ]
                    .compactMap { $0 }
                )
            }

            if snapshot.months > 0 {
                return language.join(
                    [
                        language.monthUnit(snapshot.months, locale: locale),
                        snapshot.days > 0
                            ? language.dayUnit(snapshot.days, locale: locale)
                            : nil
                    ]
                    .compactMap { $0 }
                )
            }

            return language.dayUnit(totalDays, locale: locale)
        case .month:
            guard let totalMonths = snapshot.totalMonths,
                  totalMonths > 0 else {
                return localized(
                    english: "This month",
                    japanese: "今月",
                    locale: locale
                )
            }

            if snapshot.years > 0 {
                return language.join(
                    [
                        language.yearUnit(snapshot.years, locale: locale),
                        snapshot.months > 0
                            ? language.monthUnit(snapshot.months, locale: locale)
                            : nil
                    ]
                    .compactMap { $0 }
                )
            }

            return language.monthUnit(totalMonths, locale: locale)
        case .year:
            guard snapshot.years > 0 else {
                return localized(
                    english: "This year",
                    japanese: "今年",
                    locale: locale
                )
            }

            return language.yearUnit(snapshot.years, locale: locale)
        }
    }

    public static func detailElapsedText(
        for snapshot: EntryElapsedSnapshot,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let language = FluelLocale(locale: locale)

        switch snapshot.precision {
        case .day:
            guard let totalDays = snapshot.totalDays,
                  totalDays > 0 else {
                return localized(
                    english: "Today",
                    japanese: "今日",
                    locale: locale
                )
            }

            return language.join(
                [
                    snapshot.years > 0
                        ? language.yearUnit(snapshot.years, locale: locale)
                        : nil,
                    snapshot.months > 0
                        ? language.monthUnit(snapshot.months, locale: locale)
                        : nil,
                    snapshot.days > 0
                        ? language.dayUnit(snapshot.days, locale: locale)
                        : nil
                ]
                .compactMap { $0 }
            )
        case .month:
            guard let totalMonths = snapshot.totalMonths,
                  totalMonths > 0 else {
                return localized(
                    english: "This month",
                    japanese: "今月",
                    locale: locale
                )
            }

            return language.join(
                [
                    snapshot.years > 0
                        ? language.yearUnit(snapshot.years, locale: locale)
                        : nil,
                    snapshot.months > 0
                        ? language.monthUnit(snapshot.months, locale: locale)
                        : nil
                ]
                .compactMap { $0 }
            )
        case .year:
            guard snapshot.years > 0 else {
                return localized(
                    english: "This year",
                    japanese: "今年",
                    locale: locale
                )
            }

            return language.yearUnit(snapshot.years, locale: locale)
        }
    }

    public static func totalMeasureText(
        for snapshot: EntryElapsedSnapshot,
        locale: Locale = .autoupdatingCurrent
    ) -> String? {
        let language = FluelLocale(locale: locale)

        if let totalDays = snapshot.totalDays {
            return language.dayUnit(totalDays, locale: locale)
        }

        if let totalMonths = snapshot.totalMonths {
            return language.monthUnit(totalMonths, locale: locale)
        }

        return nil
    }

    public static func startDateText(
        for startComponents: EntryStartComponents,
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent
    ) -> String {
        let resolvedDate = startComponents.earliestDate(calendar: calendar) ?? .now

        switch startComponents.precision {
        case .day:
            return resolvedDate.formatted(
                .dateTime
                    .year()
                    .month(.abbreviated)
                    .day()
                    .locale(locale)
            )
        case .month:
            return resolvedDate.formatted(
                .dateTime
                    .year()
                    .month(.abbreviated)
                    .locale(locale)
            )
        case .year:
            let language = FluelLocale(locale: locale)
            let year = startComponents.year.formatted(
                .number
                    .grouping(.never)
                    .locale(locale)
            )

            if language == .japanese {
                return "\(year)年"
            }

            return year
        }
    }

    public static func startLabelText(
        for startComponents: EntryStartComponents,
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent
    ) -> String {
        let dateText = startDateText(
            for: startComponents,
            locale: locale,
            calendar: calendar
        )

        switch FluelLocale(locale: locale) {
        case .english:
            return "Since \(dateText)"
        case .japanese:
            return "\(dateText)から"
        }
    }

    public static func startRangeText(
        for startComponents: EntryStartComponents,
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent
    ) -> String? {
        let resolvedDate = startComponents.earliestDate(calendar: calendar) ?? .now

        switch (startComponents.precision, FluelLocale(locale: locale)) {
        case (.day, _):
            return nil
        case (.month, .english):
            let dateText = resolvedDate.formatted(
                .dateTime
                    .month(.abbreviated)
                    .year()
                    .locale(locale)
            )

            return "Sometime in \(dateText)"
        case (.month, .japanese):
            let yearText = startComponents.year.formatted(
                .number
                    .grouping(.never)
                    .locale(locale)
            )
            let monthText = startComponents.month?.formatted(
                .number
                    .grouping(.never)
                    .locale(locale)
            ) ?? String()

            return "\(yearText)年\(monthText)月のどこか"
        case (.year, .english):
            let yearText = startComponents.year.formatted(
                .number
                    .grouping(.never)
                    .locale(locale)
            )

            return "Sometime in \(yearText)"
        case (.year, .japanese):
            let yearText = startComponents.year.formatted(
                .number
                    .grouping(.never)
                    .locale(locale)
            )

            return "\(yearText)年のどこか"
        }
    }

    public static func precisionText(
        for precision: EntryDatePrecision,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        switch (precision, FluelLocale(locale: locale)) {
        case (.day, .english):
            return "Exact day"
        case (.day, .japanese):
            return "日まで分かる"
        case (.month, .english):
            return "Known to the month"
        case (.month, .japanese):
            return "月まで分かる"
        case (.year, .english):
            return "Known to the year"
        case (.year, .japanese):
            return "年まで分かる"
        }
    }

    public static func activeCountText(
        _ count: Int,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let language = FluelLocale(locale: locale)
        let number = language.numberText(count, locale: locale)

        switch language {
        case .english:
            if count == 1 {
                return "\(number) active entry"
            }

            return "\(number) active entries"
        case .japanese:
            return "\(number)件を記録中"
        }
    }

    public static func notePreviewText(
        _ note: String?
    ) -> String? {
        guard let note else {
            return nil
        }

        let preview = note
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.isEmpty == false }
            .joined(separator: " ")

        guard preview.isEmpty == false else {
            return nil
        }

        return preview
    }

    public static func noteCharacterCountText(
        _ note: String?,
        locale: Locale = .autoupdatingCurrent
    ) -> String? {
        guard let note,
              note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return nil
        }

        let language = FluelLocale(locale: locale)
        let number = language.numberText(note.count, locale: locale)

        switch language {
        case .english:
            if note.count == 1 {
                return "\(number) character"
            }

            return "\(number) characters"
        case .japanese:
            return "\(number)文字"
        }
    }

    public static func metadataBadgeTexts(
        for entry: Entry,
        locale: Locale = .autoupdatingCurrent
    ) -> [String] {
        var badges = [String]()

        if entry.photoData?.isEmpty == false {
            badges.append(
                localized(
                    english: "Photo",
                    japanese: "写真",
                    locale: locale
                )
            )
        }

        if notePreviewText(entry.note) != nil {
            badges.append(
                localized(
                    english: "Note",
                    japanese: "メモ",
                    locale: locale
                )
            )
        }

        if entry.startPrecision != .day {
            badges.append(
                localized(
                    english: "Approximate start",
                    japanese: "開始はおおよそ",
                    locale: locale
                )
            )
        }

        return badges
    }

    public static func archivedFooterText(
        archivedAt: Date,
        note: String?,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let archivedText = archivedOnText(
            archivedAt,
            locale: locale
        )

        guard let notePreview = notePreviewText(note) else {
            return archivedText
        }

        return "\(archivedText) | \(notePreview)"
    }

    public static func archivedOnText(
        _ date: Date,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let formattedDate = date.formatted(
            .dateTime
                .year()
                .month(.abbreviated)
                .day()
                .locale(locale)
        )

        switch FluelLocale(locale: locale) {
        case .english:
            return "Archived on \(formattedDate)"
        case .japanese:
            return "\(formattedDate)に保管済み"
        }
    }
}

private extension EntryFormatting {
    static func localized(
        english: String,
        japanese: String,
        locale: Locale
    ) -> String {
        switch FluelLocale(locale: locale) {
        case .english:
            return english
        case .japanese:
            return japanese
        }
    }
}
