import Foundation
import SwiftData

/// Domain errors raised while mutating entries.
public enum EntryRepositoryError: LocalizedError, Equatable {
    case emptyTitle
    case invalidStartDate
    case futureStartDate

    public var errorDescription: String? {
        switch (self, FluelLocale(locale: .autoupdatingCurrent)) {
        case (.emptyTitle, .english):
            return "Enter a title."
        case (.emptyTitle, .japanese):
            return "名前を入力してください。"
        case (.invalidStartDate, .english):
            return "Choose a valid start date."
        case (.invalidStartDate, .japanese):
            return "開始時期を確認してください。"
        case (.futureStartDate, .english):
            return "The start date needs to be in the past or today."
        case (.futureStartDate, .japanese):
            return "開始時期は今日以前を選んでください。"
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
