import Foundation
import SwiftData

/// Aggregate snapshot for active and archived entry collections.
public struct EntryCollectionSnapshot: Equatable, Sendable {
    public let totalCount: Int
    public let activeCount: Int
    public let archivedCount: Int
    public let activeWithNotesCount: Int
    public let activeWithPhotosCount: Int
    public let archivedWithNotesCount: Int
    public let archivedWithPhotosCount: Int
    public let leadActiveTitle: String?
    public let leadActiveStartComponents: EntryStartComponents?
    public let leadActiveElapsedSnapshot: EntryElapsedSnapshot?
    public let mostRecentlyArchivedTitle: String?

    public init(
        totalCount: Int,
        activeCount: Int,
        archivedCount: Int,
        activeWithNotesCount: Int,
        activeWithPhotosCount: Int,
        archivedWithNotesCount: Int,
        archivedWithPhotosCount: Int,
        leadActiveTitle: String?,
        leadActiveStartComponents: EntryStartComponents?,
        leadActiveElapsedSnapshot: EntryElapsedSnapshot?,
        mostRecentlyArchivedTitle: String?
    ) {
        self.totalCount = totalCount
        self.activeCount = activeCount
        self.archivedCount = archivedCount
        self.activeWithNotesCount = activeWithNotesCount
        self.activeWithPhotosCount = activeWithPhotosCount
        self.archivedWithNotesCount = archivedWithNotesCount
        self.archivedWithPhotosCount = archivedWithPhotosCount
        self.leadActiveTitle = leadActiveTitle
        self.leadActiveStartComponents = leadActiveStartComponents
        self.leadActiveElapsedSnapshot = leadActiveElapsedSnapshot
        self.mostRecentlyArchivedTitle = mostRecentlyArchivedTitle
    }
}

/// Query helpers that derive aggregate counts and highlights from entries.
public enum EntryCollectionSnapshotQuery {
    public static func snapshot(
        context: ModelContext,
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) throws -> EntryCollectionSnapshot {
        snapshot(
            entries: try EntryRepository.fetchAllEntries(context: context),
            referenceDate: referenceDate,
            calendar: calendar
        )
    }

    public static func snapshot(
        entries: [Entry],
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> EntryCollectionSnapshot {
        let activeEntries = entries.filter { entry in
            entry.isArchived == false
        }
        let archivedEntries = entries.filter(\.isArchived)
        let leadActiveEntry = EntryListOrdering.leadActiveEntry(
            from: activeEntries,
            calendar: calendar
        )
        let mostRecentlyArchivedEntry = EntryListOrdering.archived(
            archivedEntries,
            sortMode: .recentlyArchived,
            calendar: calendar
        ).first

        return .init(
            totalCount: entries.count,
            activeCount: activeEntries.count,
            archivedCount: archivedEntries.count,
            activeWithNotesCount: activeEntries.count(where: hasNote),
            activeWithPhotosCount: activeEntries.count(where: hasPhoto),
            archivedWithNotesCount: archivedEntries.count(where: hasNote),
            archivedWithPhotosCount: archivedEntries.count(where: hasPhoto),
            leadActiveTitle: leadActiveEntry?.title,
            leadActiveStartComponents: leadActiveEntry?.startComponents,
            leadActiveElapsedSnapshot: leadActiveEntry.map { entry in
                EntryElapsedSnapshot(
                    startComponents: entry.startComponents,
                    referenceDate: referenceDate,
                    calendar: calendar
                )
            },
            mostRecentlyArchivedTitle: mostRecentlyArchivedEntry?.title
        )
    }
}

private extension EntryCollectionSnapshotQuery {
    static func hasNote(
        _ entry: Entry
    ) -> Bool {
        EntryFormatting.notePreviewText(entry.note) != nil
    }

    static func hasPhoto(
        _ entry: Entry
    ) -> Bool {
        entry.photoData?.isEmpty == false
    }
}
