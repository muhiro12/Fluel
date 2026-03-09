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

            if language == .japanese || language == .simplifiedChinese {
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
        case .spanish:
            return "Desde \(dateText)"
        case .french:
            return "Depuis \(dateText)"
        case .simplifiedChinese:
            return "从\(dateText)开始"
        }
    }

    public static func formStartSummaryText(
        for startComponents: EntryStartComponents,
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent
    ) -> String {
        let dateText = startDateText(
            for: startComponents,
            locale: locale,
            calendar: calendar
        )

        switch (startComponents.precision, FluelLocale(locale: locale)) {
        case (.day, .english):
            return "Starts on \(dateText)"
        case (.day, .japanese):
            return "\(dateText)に始まる"
        case (.day, .spanish):
            return "Empieza el \(dateText)"
        case (.day, .french):
            return "Commence le \(dateText)"
        case (.day, .simplifiedChinese):
            return "始于\(dateText)"
        case (.month, .english):
            return "Starts sometime in \(dateText)"
        case (.month, .japanese):
            return "\(dateText)のどこかで始まる"
        case (.month, .spanish):
            return "Empieza en algún momento de \(dateText)"
        case (.month, .french):
            return "Commence à un moment de \(dateText)"
        case (.month, .simplifiedChinese):
            return "大约始于\(dateText)"
        case (.year, .english):
            return "Starts sometime in \(dateText)"
        case (.year, .japanese):
            return "\(dateText)のどこかで始まる"
        case (.year, .spanish):
            return "Empieza en algún momento de \(dateText)"
        case (.year, .french):
            return "Commence à un moment de \(dateText)"
        case (.year, .simplifiedChinese):
            return "大约始于\(dateText)"
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
        case (.month, .spanish):
            let dateText = resolvedDate.formatted(
                .dateTime
                    .month(.abbreviated)
                    .year()
                    .locale(locale)
            )

            return "En algún momento de \(dateText)"
        case (.month, .french):
            let dateText = resolvedDate.formatted(
                .dateTime
                    .month(.abbreviated)
                    .year()
                    .locale(locale)
            )

            return "À un moment de \(dateText)"
        case (.month, .simplifiedChinese):
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

            return "\(yearText)年\(monthText)月左右"
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
        case (.year, .spanish):
            let yearText = startComponents.year.formatted(
                .number
                    .grouping(.never)
                    .locale(locale)
            )

            return "En algún momento de \(yearText)"
        case (.year, .french):
            let yearText = startComponents.year.formatted(
                .number
                    .grouping(.never)
                    .locale(locale)
            )

            return "À un moment de \(yearText)"
        case (.year, .simplifiedChinese):
            let yearText = startComponents.year.formatted(
                .number
                    .grouping(.never)
                    .locale(locale)
            )

            return "\(yearText)年左右"
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
        case (.day, .spanish):
            return "Día exacto"
        case (.day, .french):
            return "Jour exact"
        case (.day, .simplifiedChinese):
            return "精确到日"
        case (.month, .english):
            return "Known to the month"
        case (.month, .japanese):
            return "月まで分かる"
        case (.month, .spanish):
            return "Conocido hasta el mes"
        case (.month, .french):
            return "Connu jusqu'au mois"
        case (.month, .simplifiedChinese):
            return "精确到月"
        case (.year, .english):
            return "Known to the year"
        case (.year, .japanese):
            return "年まで分かる"
        case (.year, .spanish):
            return "Conocido hasta el año"
        case (.year, .french):
            return "Connu jusqu'à l'année"
        case (.year, .simplifiedChinese):
            return "精确到年"
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
        case .spanish:
            if count == 1 {
                return "\(number) registro activo"
            }

            return "\(number) registros activos"
        case .french:
            if count == 1 {
                return "\(number) entrée active"
            }

            return "\(number) entrées actives"
        case .simplifiedChinese:
            return "记录中 \(number) 条"
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
        case .spanish:
            if note.count == 1 {
                return "\(number) carácter"
            }

            return "\(number) caracteres"
        case .french:
            if note.count == 1 {
                return "\(number) caractère"
            }

            return "\(number) caractères"
        case .simplifiedChinese:
            return "\(number) 个字符"
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
        case .spanish:
            return "Archivado el \(formattedDate)"
        case .french:
            return "Archivé le \(formattedDate)"
        case .simplifiedChinese:
            return "已于\(formattedDate)归档"
        }
    }

    public static func createdOnText(
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
            return "Created on \(formattedDate)"
        case .japanese:
            return "\(formattedDate)に作成"
        case .spanish:
            return "Creado el \(formattedDate)"
        case .french:
            return "Créé le \(formattedDate)"
        case .simplifiedChinese:
            return "创建于\(formattedDate)"
        }
    }

    public static func updatedOnText(
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
            return "Updated on \(formattedDate)"
        case .japanese:
            return "\(formattedDate)に更新"
        case .spanish:
            return "Actualizado el \(formattedDate)"
        case .french:
            return "Mis à jour le \(formattedDate)"
        case .simplifiedChinese:
            return "更新于\(formattedDate)"
        }
    }

    public static func archivedDurationText(
        startComponents: EntryStartComponents,
        archivedAt: Date,
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent
    ) -> String {
        let snapshot = EntryElapsedSnapshot(
            startComponents: startComponents,
            referenceDate: archivedAt,
            calendar: calendar
        )

        return detailElapsedText(
            for: snapshot,
            locale: locale
        )
    }
}

private extension EntryFormatting {
    static func localized(
        english: String,
        japanese: String,
        locale: Locale
    ) -> String {
        FluelLocalization.string(
            key: english,
            defaultValue: english,
            japaneseFallback: japanese,
            bundle: .module,
            locale: locale
        )
    }
}
