import Foundation

public extension EntryOperations {
    /// Returns the activity created when an entry is added.
    static func addedActivity(
        for snapshot: EntrySnapshot,
        id: UUID = .init()
    ) -> EntryActivitySummary {
        .init(
            entryID: snapshot.id,
            title: snapshot.title,
            kind: .added,
            date: snapshot.createdAt,
            id: id
        )
    }

    /// Returns the activity created when an entry is updated.
    static func updatedActivity(
        for snapshot: EntrySnapshot,
        id: UUID = .init()
    ) -> EntryActivitySummary {
        .init(
            entryID: snapshot.id,
            title: snapshot.title,
            kind: .updated,
            date: snapshot.updatedAt,
            id: id
        )
    }

    /// Returns the activity created when an entry is archived.
    static func archivedActivity(
        for snapshot: EntrySnapshot,
        id: UUID = .init()
    ) -> EntryActivitySummary? {
        guard let archivedAt = snapshot.archivedAt else {
            return nil
        }

        return .init(
            entryID: snapshot.id,
            title: snapshot.title,
            kind: .archived,
            date: archivedAt,
            id: id
        )
    }
}
