import FluelLibrary
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

    static func share(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Share",
            japanese: "共有",
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

    static func delete(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Delete",
            japanese: "削除",
            locale: locale
        )
    }

    static func deletePermanently(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Delete Permanently",
            japanese: "完全に削除",
            locale: locale
        )
    }

    static func deleteConfirmationTitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Delete this entry?",
            japanese: "この記録を削除しますか？",
            locale: locale
        )
    }

    static func deleteConfirmationMessage(
        for entryTitle: String,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "\"\(entryTitle)\" will be permanently removed from Fluel.",
            japanese: "「\(entryTitle)」を Fluel から完全に削除します。",
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

    static func searchEntries(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Search entries",
            japanese: "記録を検索",
            locale: locale
        )
    }

    static func sort(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Sort",
            japanese: "並び順",
            locale: locale
        )
    }

    static func filter(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Filter",
            japanese: "絞り込み",
            locale: locale
        )
    }

    static func clearSearch(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Clear search",
            japanese: "検索をクリア",
            locale: locale
        )
    }

    static func clearFilter(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Clear filter",
            japanese: "絞り込みを解除",
            locale: locale
        )
    }

    static func entryContentFilterMode(
        _ mode: EntryContentFilterMode,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        switch mode {
        case .all:
            return localized(
                english: "All",
                japanese: "すべて",
                locale: locale
            )
        case .withNote:
            return localized(
                english: "With note",
                japanese: "メモあり",
                locale: locale
            )
        case .withPhoto:
            return localized(
                english: "With photo",
                japanese: "写真あり",
                locale: locale
            )
        }
    }

    static func activeSortMode(
        _ sortMode: ActiveEntrySortMode,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        switch sortMode {
        case .oldestFirst:
            return localized(
                english: "Longest together",
                japanese: "長く一緒にいる順",
                locale: locale
            )
        case .newestFirst:
            return localized(
                english: "Most recent start",
                japanese: "最近始まった順",
                locale: locale
            )
        case .alphabetical:
            return localized(
                english: "Alphabetical",
                japanese: "名前順",
                locale: locale
            )
        case .recentlyUpdated:
            return localized(
                english: "Recently updated",
                japanese: "最近更新した順",
                locale: locale
            )
        }
    }

    static func archivedSortMode(
        _ sortMode: ArchivedEntrySortMode,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        switch sortMode {
        case .recentlyArchived:
            return localized(
                english: "Recently archived",
                japanese: "最近保管した順",
                locale: locale
            )
        case .oldestArchived:
            return localized(
                english: "Oldest archived",
                japanese: "古く保管した順",
                locale: locale
            )
        case .longestTogether:
            return localized(
                english: "Longest together",
                japanese: "長く一緒にいた順",
                locale: locale
            )
        case .alphabetical:
            return localized(
                english: "Alphabetical",
                japanese: "名前順",
                locale: locale
            )
        }
    }

    static func homeSearchEmptyTitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "No active entries matched",
            japanese: "一致する記録がありません",
            locale: locale
        )
    }

    static func homeSearchEmptyBody(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Try another filter or word from the title or note.",
            japanese: "絞り込みや、名前・メモに含まれる別の言葉で試してください。",
            locale: locale
        )
    }

    static func archiveSearchEmptyTitle(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "No archived entries matched",
            japanese: "一致する保管済み記録がありません",
            locale: locale
        )
    }

    static func archiveSearchEmptyBody(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Try another filter or word from the title, note, or archived entries.",
            japanese: "絞り込みや、名前・メモに含まれる別の言葉で探してみてください。",
            locale: locale
        )
    }

    static func activeEntryCount(
        _ count: Int,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let english = count == 1
            ? "1 active entry"
            : "\(count) active entries"

        return localized(
            english: english,
            japanese: "進行中の記録 \(count)件",
            locale: locale
        )
    }

    static func archivedEntryCount(
        _ count: Int,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let english = count == 1
            ? "1 archived entry"
            : "\(count) archived entries"

        return localized(
            english: english,
            japanese: "保管済みの記録 \(count)件",
            locale: locale
        )
    }

    static func showingEntries(
        displayedCount: Int,
        totalCount: Int,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Showing \(displayedCount) of \(totalCount)",
            japanese: "\(totalCount)件中 \(displayedCount)件を表示",
            locale: locale
        )
    }

    static func withNotesCount(
        _ count: Int,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "With notes: \(count)",
            japanese: "メモあり \(count)件",
            locale: locale
        )
    }

    static func withPhotosCount(
        _ count: Int,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "With photos: \(count)",
            japanese: "写真あり \(count)件",
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

    static func clearNote(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Clear Note",
            japanese: "メモを消す",
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

    static func startRange(
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        localized(
            english: "Start range",
            japanese: "始まりの幅",
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
