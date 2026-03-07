import Foundation

/// Shared share-sheet text generator for one entry.
public enum EntryShareTextFormatter {
    public static func text(
        for entry: Entry,
        referenceDate: Date = .now,
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent
    ) -> String {
        let snapshot = EntryElapsedSnapshot(
            startComponents: entry.startComponents,
            referenceDate: referenceDate,
            calendar: calendar
        )

        var lines = [
            entry.title,
            labeledLine(
                title: localized(
                    english: "Time together",
                    japanese: "重なってきた時間",
                    locale: locale
                ),
                value: EntryFormatting.primaryElapsedText(
                    for: snapshot,
                    locale: locale
                )
            ),
            labeledLine(
                title: localized(
                    english: "Started",
                    japanese: "始まり",
                    locale: locale
                ),
                value: EntryFormatting.startLabelText(
                    for: entry.startComponents,
                    locale: locale,
                    calendar: calendar
                )
            ),
            labeledLine(
                title: localized(
                    english: "Known as",
                    japanese: "分かる範囲",
                    locale: locale
                ),
                value: EntryFormatting.precisionText(
                    for: entry.startPrecision,
                    locale: locale
                )
            )
        ]

        if let note = entry.note,
           note.isEmpty == false {
            lines.append(
                labeledLine(
                    title: localized(
                        english: "Note",
                        japanese: "メモ",
                        locale: locale
                    ),
                    value: note
                )
            )
        }

        if let archivedAt = entry.archivedAt {
            lines.append(
                labeledLine(
                    title: localized(
                        english: "Archived",
                        japanese: "保管",
                        locale: locale
                    ),
                    value: EntryFormatting.archivedOnText(
                        archivedAt,
                        locale: locale
                    )
                )
            )
        }

        return lines.joined(separator: "\n")
    }
}

private extension EntryShareTextFormatter {
    static func labeledLine(
        title: String,
        value: String
    ) -> String {
        "\(title): \(value)"
    }

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
