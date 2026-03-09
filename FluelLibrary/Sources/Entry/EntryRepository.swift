import Foundation
import SwiftData

/// Domain errors raised while mutating entries.
public enum EntryRepositoryError: LocalizedError, Equatable {
    case emptyTitle
    case invalidStartDate
    case futureStartDate
    case deleteRequiresArchivedEntry

    public var errorDescription: String? {
        Self.localizedDescription(
            for: self,
            locale: .autoupdatingCurrent
        )
    }

    static func localizedDescription(
        for error: Self,
        locale: Locale
    ) -> String {
        switch (error, FluelLocale(locale: locale)) {
        case (.emptyTitle, .english):
            return "Enter a title."
        case (.emptyTitle, .japanese):
            return "名前を入力してください。"
        case (.emptyTitle, .spanish):
            return "Introduce un nombre."
        case (.emptyTitle, .french):
            return "Saisissez un nom."
        case (.emptyTitle, .simplifiedChinese):
            return "请输入名称。"
        case (.invalidStartDate, .english):
            return "Choose a valid start date."
        case (.invalidStartDate, .japanese):
            return "開始時期を確認してください。"
        case (.invalidStartDate, .spanish):
            return "Elige una fecha de inicio válida."
        case (.invalidStartDate, .french):
            return "Choisissez une date de début valide."
        case (.invalidStartDate, .simplifiedChinese):
            return "请选择有效的开始日期。"
        case (.futureStartDate, .english):
            return "The start date needs to be in the past or today."
        case (.futureStartDate, .japanese):
            return "開始時期は今日以前を選んでください。"
        case (.futureStartDate, .spanish):
            return "La fecha de inicio debe ser hoy o anterior."
        case (.futureStartDate, .french):
            return "La date de début doit être aujourd'hui ou antérieure."
        case (.futureStartDate, .simplifiedChinese):
            return "开始日期必须是今天或更早。"
        case (.deleteRequiresArchivedEntry, .english):
            return "Archive the entry before deleting it."
        case (.deleteRequiresArchivedEntry, .japanese):
            return "削除する前に、この記録を保管済みにしてください。"
        case (.deleteRequiresArchivedEntry, .spanish):
            return "Archiva el registro antes de eliminarlo."
        case (.deleteRequiresArchivedEntry, .french):
            return "Archivez l'entrée avant de la supprimer."
        case (.deleteRequiresArchivedEntry, .simplifiedChinese):
            return "删除前请先将该记录归档。"
        }
    }
}

/// Shared mutation and query helpers for entries.
public enum EntryRepository {
    @discardableResult
    public static func create(
        context: ModelContext,
        input: EntryFormInput,
        now: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) throws -> Entry {
        let entry = try Entry.create(
            context: context,
            input: input,
            now: now,
            calendar: calendar
        )

        try context.save()

        return entry
    }

    public static func update(
        context: ModelContext,
        entry: Entry,
        input: EntryFormInput,
        now: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) throws {
        try entry.update(
            input: input,
            now: now,
            calendar: calendar
        )

        try context.save()
    }

    public static func archive(
        context: ModelContext,
        entry: Entry,
        now: Date = .now
    ) throws {
        entry.archive(now: now)
        try context.save()
    }

    public static func restore(
        context: ModelContext,
        entry: Entry,
        now: Date = .now
    ) throws {
        entry.restore(now: now)
        try context.save()
    }

    public static func delete(
        context: ModelContext,
        entry: Entry
    ) throws {
        guard entry.isArchived else {
            throw EntryRepositoryError.deleteRequiresArchivedEntry
        }

        context.delete(entry)
        try context.save()
    }

    public static func fetchAllEntries(
        context: ModelContext
    ) throws -> [Entry] {
        try context.fetch(FetchDescriptor<Entry>())
    }

    public static func fetchActiveEntries(
        context: ModelContext,
        calendar: Calendar = .autoupdatingCurrent
    ) throws -> [Entry] {
        let entries = try context.fetch(
            FetchDescriptor<Entry>(
                predicate: #Predicate<Entry> { entry in
                    entry.archivedAt == nil
                }
            )
        )

        return EntryListOrdering.active(
            entries,
            calendar: calendar
        )
    }

    public static func fetchArchivedEntries(
        context: ModelContext
    ) throws -> [Entry] {
        let entries = try context.fetch(
            FetchDescriptor<Entry>(
                predicate: #Predicate<Entry> { entry in
                    entry.archivedAt != nil
                }
            )
        )

        return EntryListOrdering.archived(entries)
    }
}
