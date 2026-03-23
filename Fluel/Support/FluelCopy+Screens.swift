import Foundation

private enum FluelScreenCopyLocale {
    case english
    case japanese
    case spanish
    case french
    case simplifiedChinese

    init(locale: Locale) {
        let languageIdentifier =
            locale.language.languageCode?.identifier
            ?? locale.identifier

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

extension FluelCopy {
    static func homeScreenSubtitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "See the time that has quietly gathered with the things "
                + "and places you live with.",
            japanese: "身の回りのものや場所と重なってきた時間を、静かに見渡せます。",
            locale: locale
        )
    }

    static func archiveScreenSubtitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "What has moved out of daily life stays here, readable "
                + "and separate.",
            japanese: "日々のそばを離れたものも、ここで静かに読み返せます。",
            locale: locale
        )
    }

    static func homeFilterEmptyTitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "No active entries match this filter",
            japanese: "この絞り込みに一致する記録はありません",
            locale: locale
        )
    }

    static func homeFilterEmptyBody(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Try another filter to bring back the entries you are still living with.",
            japanese: "絞り込みを変えると、いま一緒にある記録が見つかるかもしれません。",
            locale: locale
        )
    }

    static func archiveFilterEmptyTitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "No archived entries match this filter",
            japanese: "この絞り込みに一致する保管済み記録はありません",
            locale: locale
        )
    }

    static func archiveFilterEmptyBody(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Try another filter to see more of what has already been archived.",
            japanese: "絞り込みを変えると、保管済みの記録が見つかるかもしれません。",
            locale: locale
        )
    }

    static func dashboardScreenSubtitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "See the whole shape of what is still with you and what "
                + "has already been archived.",
            japanese: "いま一緒にあるものと、保管済みになったものの全体像を静かに見渡せます。",
            locale: locale
        )
    }

    static func timelineScreenSubtitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Read back the quiet sequence of entries being added, adjusted, and archived.",
            japanese: "記録の追加、更新、保管が積もってきた流れを、静かに読み返せます。",
            locale: locale
        )
    }

    static func settingsScreenSubtitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Adjust how Fluel surfaces the quiet information it keeps.",
            japanese: "Fluel が静かに見せる情報の出し方を整えられます。",
            locale: locale
        )
    }

    static func resetDisplayPreferences(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Reset display preferences",
            japanese: "表示設定を初期化",
            locale: locale
        )
    }

    static func resetDisplayPreferencesConfirmationTitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Reset display preferences?",
            japanese: "表示設定を初期化しますか？",
            locale: locale
        )
    }

    static func resetDisplayPreferencesConfirmationMessage(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "List summaries, note previews, metadata badges, and "
                + "dashboard highlights will return to their default visibility.",
            japanese: "一覧サマリー、メモのプレビュー、メタデータバッジ、ダッシュボードのハイライト表示が初期状態に戻ります。",
            locale: locale
        )
    }

    static func displayPreferencesResetNotice(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Display preferences were reset.",
            japanese: "表示設定を初期状態に戻しました。",
            locale: locale
        )
    }

    static func tipsResetNotice(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Tips were reset and can appear again.",
            japanese: "ヒントを初期化しました。再び表示されます。",
            locale: locale
        )
    }

    static func tipsResetFailedNotice(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Tips could not be reset right now.",
            japanese: "いまはヒントを初期化できませんでした。",
            locale: locale
        )
    }

    static func dismissNotice(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Dismiss notice",
            japanese: "通知を閉じる",
            locale: locale
        )
    }

    static func activeDefaultPresetSummary(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "New entries start from this preset.",
            japanese: "新しい記録はこのプリセットから始まります。",
            locale: locale
        )
    }

    static func inactiveDefaultPresetSummary(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "This preset is selected, but new entries still start blank.",
            japanese: "このプリセットは選択されていますが、新しい記録はまだ空の状態から始まります。",
            locale: locale
        )
    }

    static func defaultPresetSelectedNotice(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "The default preset was updated.",
            japanese: "既定のプリセットを更新しました。",
            locale: locale
        )
    }

    static func defaultPresetClearedNotice(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "The default preset was cleared.",
            japanese: "既定のプリセットを解除しました。",
            locale: locale
        )
    }

    static func presetPinnedNotice(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "The preset was pinned.",
            japanese: "プリセットを固定しました。",
            locale: locale
        )
    }

    static func presetUnpinnedNotice(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "The preset was unpinned.",
            japanese: "プリセットの固定を解除しました。",
            locale: locale
        )
    }

    static func defaultDisplayPreferencesSummary(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "All display preferences are using their defaults.",
            japanese: "表示設定はすべて初期状態です。",
            locale: locale
        )
    }

    static func customizedDisplayPreferenceCount(
        _ count: Int,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let language = FluelScreenCopyLocale(locale: locale)
        let number = count.formatted(
            .number
                .locale(locale)
        )

        switch language {
        case .english:
            return count == 1
                ? "\(number) display preference is customized"
                : "\(number) display preferences are customized"
        case .japanese:
            return "表示設定を \(number) 件カスタマイズ中"
        case .spanish:
            return count == 1
                ? "\(number) preferencia de visualización personalizada"
                : "\(number) preferencias de visualización personalizadas"
        case .french:
            return count == 1
                ? "\(number) préférence d’affichage personnalisée"
                : "\(number) préférences d’affichage personnalisées"
        case .simplifiedChinese:
            return "已自定义 \(number) 项显示设置"
        }
    }

    static func createScreenSubtitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Add one thing or place you live with.",
            japanese: "一緒に暮らしているものや場所をひとつ加えます。",
            locale: locale
        )
    }

    static func editScreenSubtitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Adjust what you know, including how precisely the start "
                + "is known.",
            japanese: "始まりをどこまで分かっているかも含めて、静かに整えられます。",
            locale: locale
        )
    }

    static func timeTogetherSectionTitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Time together",
            japanese: "重なってきた時間",
            locale: locale
        )
    }

    static func timeTogetherSectionBody(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "A quiet view of how long this has been with you.",
            japanese: "どれくらい長くそばにあるかを、落ち着いて見られます。",
            locale: locale
        )
    }

    static func detailsSectionTitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Details",
            japanese: "詳細",
            locale: locale
        )
    }

    static func detailsSectionBody(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "The start and its precision stay exactly as you know "
                + "them.",
            japanese: "始まりと、その分かる範囲をそのまま残します。",
            locale: locale
        )
    }
}
