import FluelLibrary
import Foundation

struct LeadEntryWidgetLocalization {
    private let locale: Locale

    init(
        locale: Locale = .autoupdatingCurrent
    ) {
        self.locale = locale
    }

    var emptyTitle: String {
        localized(
            english: "Nothing yet",
            japanese: "まだありません"
        )
    }

    var emptyBody: String {
        localized(
            english: "Add an entry in Fluel to quietly keep time with it.",
            japanese: "Fluel で記録を追加すると、その時間が静かに見えてきます。"
        )
    }

    var activeMetricLabel: String {
        localized(
            english: "Active",
            japanese: "記録中"
        )
    }

    var archivedMetricLabel: String {
        localized(
            english: "Archived",
            japanese: "保管済み"
        )
    }

    var notesMetricLabel: String {
        localized(
            english: "Notes",
            japanese: "メモあり"
        )
    }

    var photosMetricLabel: String {
        localized(
            english: "Photos",
            japanese: "写真あり"
        )
    }

    var upcomingTitle: String {
        localized(
            english: "Upcoming",
            japanese: "次の節目"
        )
    }

    var recentTitle: String {
        localized(
            english: "Recent",
            japanese: "最近の動き"
        )
    }

    var widgetDescription: String {
        localized(
            english: "Shows your longest-running entry and nearby dashboard highlights.",
            japanese: "いちばん長く一緒にいる記録と、その周辺の状況を表示します。"
        )
    }

    func recentlyArchivedText(
        for title: String
    ) -> String {
        FluelLocalization.formattedString(
            key: "widget_recently_archived_text",
            defaultValue: "Recently archived: %@",
            japaneseFallback: "最近保管: %@",
            bundle: .main,
            locale: locale,
            arguments: [title]
        )
    }

    func milestoneDetail(
        _ milestone: EntryMilestoneSnapshot
    ) -> String {
        let language = LeadEntryWidgetLocale(locale: locale)
        let number = milestone.daysRemaining.formatted(
            .number
                .locale(locale)
        )
        let approximateSuffix = milestone.isApproximate
            ? localized(
                english: "Approximate start",
                japanese: "開始時期は概算"
            )
            : nil

        let base: String
        if milestone.daysRemaining == 0 {
            switch language {
            case .english:
                base = "\(milestone.milestoneText) today"
            case .japanese:
                base = "今日で\(milestone.milestoneText)"
            case .spanish:
                base = "\(milestone.milestoneText) hoy"
            case .french:
                base = "\(milestone.milestoneText) aujourd'hui"
            case .simplifiedChinese:
                base = "今天达到\(milestone.milestoneText)"
            }
        } else {
            switch language {
            case .english:
                base = "\(milestone.milestoneText) in \(number) days"
            case .japanese:
                base = "あと\(number)日で\(milestone.milestoneText)"
            case .spanish:
                base = "\(milestone.milestoneText) en \(number) días"
            case .french:
                base = "\(milestone.milestoneText) dans \(number) jours"
            case .simplifiedChinese:
                base = "还有\(number)天达到\(milestone.milestoneText)"
            }
        }

        guard let approximateSuffix else {
            return base
        }

        return "\(base) · \(approximateSuffix)"
    }

    func activityDetail(
        _ activity: EntryActivitySnapshot
    ) -> String {
        let timestamp = activity.timestamp.formatted(
            date: .abbreviated,
            time: .omitted
        )

        return "\(activityKind(activity.kind)) · \(timestamp)"
    }
}

private enum LeadEntryWidgetLocale {
    case english
    case japanese
    case spanish
    case french
    case simplifiedChinese

    init(
        locale: Locale
    ) {
        let languageIdentifier = locale.language.languageCode?.identifier ?? locale.identifier

        if languageIdentifier.hasPrefix("ja") {
            self = .japanese
        } else if languageIdentifier.hasPrefix("es") {
            self = .spanish
        } else if languageIdentifier.hasPrefix("fr") {
            self = .french
        } else if languageIdentifier.hasPrefix("zh") {
            self = .simplifiedChinese
        } else {
            self = .english
        }
    }
}

private extension LeadEntryWidgetLocalization {
    func activityKind(
        _ kind: EntryActivityKind
    ) -> String {
        switch kind {
        case .added:
            return localized(
                english: "Added",
                japanese: "追加"
            )
        case .updated:
            return localized(
                english: "Updated",
                japanese: "更新"
            )
        case .archived:
            return localized(
                english: "Archived",
                japanese: "保管"
            )
        }
    }

    func localized(
        english: String,
        japanese: String
    ) -> String {
        FluelLocalization.string(
            key: english,
            defaultValue: english,
            japaneseFallback: japanese,
            bundle: .main,
            locale: locale
        )
    }
}
