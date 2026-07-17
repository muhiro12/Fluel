//
//  SampleDataManifest.swift
//  Fluel
//
//  Created by Codex on 2026/07/17.
//

import FluelLibrary
import Foundation

enum SampleDataManifest {
    struct EntryDefinition {
        let snapshot: EntrySnapshot
        let photoData: Data?
        let activitySummaries: [EntryActivitySummary]

        func makeEntry() -> Entry {
            Entry(
                title: snapshot.title,
                note: snapshot.note,
                photoData: photoData,
                start: snapshot.start,
                createdAt: snapshot.createdAt,
                updatedAt: snapshot.updatedAt,
                archivedAt: snapshot.archivedAt,
                id: snapshot.id
            )
        }

        func makeActivityItems() -> [EntryActivity] {
            activitySummaries.map { summary in
                EntryActivity(summary: summary)
            }
        }
    }

    enum Identifier {
        static let thisHome = uuid("10000000-0000-0000-0000-000000000001")
        static let notebook = uuid("10000000-0000-0000-0000-000000000002")
        static let watch = uuid("10000000-0000-0000-0000-000000000003")
        static let deskLamp = uuid("10000000-0000-0000-0000-000000000004")
    }

    static let entryIDs: Set<UUID> = [
        Identifier.thisHome,
        Identifier.notebook,
        Identifier.watch,
        Identifier.deskLamp
    ]

    static let entryCount = entryIDs.count

    static let samplePhotoData: Data = {
        let base64 = """
        iVBORw0KGgoAAAANSUhEUgAAAAgAAAAGCAIAAAAi2QdaAAAAG0lEQVR42mO4d+/ef4b///8z\
        MDAwMjIyMjAwAAD//wMAkf8JAnrbDWgAAAAASUVORK5CYII=
        """
        guard let photoData = Data(
            base64Encoded: base64.replacingOccurrences(of: "\n", with: "")
        ) else {
            preconditionFailure("Invalid sample photo data")
        }

        return photoData
    }()

    private static func uuid(_ value: String) -> UUID {
        guard let identifier = UUID(uuidString: value) else {
            preconditionFailure("Invalid sample data identifier: \(value)")
        }

        return identifier
    }
}
