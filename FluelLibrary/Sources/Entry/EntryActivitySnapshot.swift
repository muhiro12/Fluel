import Foundation
import SwiftData

/// User-visible activity kinds derived from entry timestamps.
public enum EntryActivityKind: String, CaseIterable, Sendable {
    case added
    case updated
    case archived
}

/// Feed-ready activity snapshot for one entry.
public struct EntryActivitySnapshot: Equatable, Sendable {
    public let entryID: UUID
    public let title: String
    public let kind: EntryActivityKind
    public let timestamp: Date

    public init(
        entryID: UUID,
        title: String,
        kind: EntryActivityKind,
        timestamp: Date
    ) {
        self.entryID = entryID
        self.title = title
        self.kind = kind
        self.timestamp = timestamp
    }
}

/// Query helpers that derive a recent activity feed from entry timestamps.
public enum EntryActivitySnapshotQuery {
    public static func recent(
        context: ModelContext,
        limit: Int = 5
    ) throws -> [EntryActivitySnapshot] {
        recent(
            entries: try EntryRepository.fetchAllEntries(context: context),
            limit: limit
        )
    }

    public static func recent(
        entries: [Entry],
        limit: Int = 5
    ) -> [EntryActivitySnapshot] {
        entries
            .compactMap(snapshot(for:))
            .sorted { lhs, rhs in
                if lhs.timestamp != rhs.timestamp {
                    return lhs.timestamp > rhs.timestamp
                }

                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
            .prefix(limit)
            .map(\.self)
    }
}

private extension EntryActivitySnapshotQuery {
    static func snapshot(
        for entry: Entry
    ) -> EntryActivitySnapshot? {
        if let archivedAt = entry.archivedAt {
            return .init(
                entryID: entry.id,
                title: entry.title,
                kind: .archived,
                timestamp: archivedAt
            )
        }

        if entry.updatedAt > entry.createdAt {
            return .init(
                entryID: entry.id,
                title: entry.title,
                kind: .updated,
                timestamp: entry.updatedAt
            )
        }

        return .init(
            entryID: entry.id,
            title: entry.title,
            kind: .added,
            timestamp: entry.createdAt
        )
    }
}
