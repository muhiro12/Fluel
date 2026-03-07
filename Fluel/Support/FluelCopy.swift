import Foundation

enum FluelCopy {
    static func add(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Add",
            japanese: "追加",
            locale: locale
        )
    }

    static func edit(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Edit",
            japanese: "編集",
            locale: locale
        )
    }

    static func save(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Save",
            japanese: "保存",
            locale: locale
        )
    }

    static func cancel(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Cancel",
            japanese: "キャンセル",
            locale: locale
        )
    }

    static func archived(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Archived",
            japanese: "保管済み",
            locale: locale
        )
    }

    static func licenses(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Licenses",
            japanese: "ライセンス",
            locale: locale
        )
    }

    static func archive(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Archive",
            japanese: "保管する",
            locale: locale
        )
    }

    static func restore(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Restore",
            japanese: "戻す",
            locale: locale
        )
    }

    static func homeEmptyTitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Begin with the things and places you live with",
            japanese: "身の回りのものや場所から始める",
            locale: locale
        )
    }

    static func homeEmptyBody(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Add a wallet, bag, shoes, watch, notebook, plant, furniture, or this home, and Fluel will quietly keep the time with it.",
            japanese: "財布、バッグ、靴、腕時計、ノート、植物、家具、この家のように、一緒に暮らしているものや場所を登録すると、その時間が静かに積もっていきます。",
            locale: locale
        )
    }

    static func addFirstEntry(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Add first entry",
            japanese: "最初の記録を追加",
            locale: locale
        )
    }

    static func archiveEmptyTitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Nothing is archived yet",
            japanese: "まだ保管済みはありません",
            locale: locale
        )
    }

    static func archiveEmptyBody(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Archived entries stay here, separate from what you still live with every day.",
            japanese: "保管済みの記録は、いまも日々を一緒にしているものとは分けてここに残ります。",
            locale: locale
        )
    }

    static func titleFieldLabel(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Title",
            japanese: "名前",
            locale: locale
        )
    }

    static func titlePlaceholder(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Wallet",
            japanese: "財布",
            locale: locale
        )
    }

    static func titleFooter(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Try wallet, bag, shoes, watch, notebook, plant, furniture, or this home.",
            japanese: "財布、バッグ、靴、腕時計、ノート、植物、家具、この家のような身近なものや場所を想定しています。",
            locale: locale
        )
    }

    static func startSectionTitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Start",
            japanese: "始まり",
            locale: locale
        )
    }

    static func precisionLabel(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Precision",
            japanese: "分かる範囲",
            locale: locale
        )
    }

    static func day(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Day",
            japanese: "日",
            locale: locale
        )
    }

    static func month(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Month",
            japanese: "月",
            locale: locale
        )
    }

    static func year(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Year",
            japanese: "年",
            locale: locale
        )
    }

    static func yearField(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Year",
            japanese: "年",
            locale: locale
        )
    }

    static func monthField(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Month",
            japanese: "月",
            locale: locale
        )
    }

    static func dayField(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Date",
            japanese: "日付",
            locale: locale
        )
    }

    static func photoSectionTitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Photo",
            japanese: "写真",
            locale: locale
        )
    }

    static func choosePhoto(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Choose Photo",
            japanese: "写真を選ぶ",
            locale: locale
        )
    }

    static func removePhoto(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Remove Photo",
            japanese: "写真を外す",
            locale: locale
        )
    }

    static func noteSectionTitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Note",
            japanese: "メモ",
            locale: locale
        )
    }

    static func notePlaceholder(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "A small note, if it matters.",
            japanese: "必要なら、短いメモを残せます。",
            locale: locale
        )
    }

    static func started(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Started",
            japanese: "始まり",
            locale: locale
        )
    }

    static func knownAs(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Known as",
            japanese: "分かる範囲",
            locale: locale
        )
    }

    static func elapsedInFull(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Elapsed in full",
            japanese: "全体では",
            locale: locale
        )
    }

    static func totalDays(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Total days",
            japanese: "合計日数",
            locale: locale
        )
    }

    static func totalMonths(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Total months",
            japanese: "合計月数",
            locale: locale
        )
    }

    static func more(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "More",
            japanese: "その他",
            locale: locale
        )
    }

    static func error(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Error",
            japanese: "エラー",
            locale: locale
        )
    }

    static func ok(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "OK",
            japanese: "OK",
            locale: locale
        )
    }

    static func localized(
        english: String,
        japanese: String,
        locale: Locale
    ) -> String {
        let languageIdentifier = locale.language.languageCode?.identifier ?? locale.identifier

        if languageIdentifier.hasPrefix("ja") {
            return japanese
        }

        return english
    }
}
