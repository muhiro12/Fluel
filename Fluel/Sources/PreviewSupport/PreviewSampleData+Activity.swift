//
//  PreviewSampleData+Activity.swift
//  Fluel
//
//  Created by Codex on 2026/07/12.
//

import FluelLibrary
import Foundation

extension PreviewSampleData {
    private enum ActivityIdentifier {
        static let thisHomeAdded = "30000000-0000-0000-0000-000000000001"
        static let notebookAdded = "30000000-0000-0000-0000-000000000002"
        static let watchAdded = "30000000-0000-0000-0000-000000000003"
        static let deskLampAdded = "30000000-0000-0000-0000-000000000004"
        static let deskLampArchived = "30000000-0000-0000-0000-000000000005"
        static let walletAdded = "30000000-0000-0000-0000-000000000006"
        static let walletUpdated = "30000000-0000-0000-0000-000000000007"
        static let bagAdded = "30000000-0000-0000-0000-000000000008"
        static let bagUpdated = "30000000-0000-0000-0000-000000000009"
        static let plantAdded = "30000000-0000-0000-0000-000000000010"
        static let plantUpdated = "30000000-0000-0000-0000-000000000011"
        static let longTitleAdded = "30000000-0000-0000-0000-000000000012"
        static let longTitleUpdated = "30000000-0000-0000-0000-000000000013"
    }

    static func activity(
        for entries: [Entry]
    ) -> [EntryActivity] {
        let entryIDs = Set(entries.map(\.id))

        return sampleActivity().filter { activity in
            entryIDs.contains(activity.entryID)
        }
    }

    private static func sampleActivity() -> [EntryActivity] {
        typicalActivity()
            + additionalAddedActivity()
            + additionalUpdatedActivity()
    }

    private static func typicalActivity() -> [EntryActivity] {
        [
            activity(
                id: ActivityIdentifier.thisHomeAdded,
                entryID: Identifier.thisHome,
                title: "This home",
                kind: .added,
                date: ReferenceDate.created
            ),
            activity(
                id: ActivityIdentifier.notebookAdded,
                entryID: Identifier.notebook,
                title: "Notebook",
                kind: .added,
                date: ReferenceDate.created
            ),
            activity(
                id: ActivityIdentifier.watchAdded,
                entryID: Identifier.watch,
                title: "Watch",
                kind: .added,
                date: ReferenceDate.created
            ),
            activity(
                id: ActivityIdentifier.deskLampAdded,
                entryID: Identifier.deskLamp,
                title: "Desk lamp",
                kind: .added,
                date: ReferenceDate.created
            ),
            activity(
                id: ActivityIdentifier.deskLampArchived,
                entryID: Identifier.deskLamp,
                title: "Desk lamp",
                kind: .archived,
                date: ReferenceDate.current
            )
        ]
    }

    private static func additionalAddedActivity() -> [EntryActivity] {
        [
            activity(
                id: ActivityIdentifier.walletAdded,
                entryID: Identifier.wallet,
                title: "Wallet",
                kind: .added,
                date: ReferenceDate.created
            ),
            activity(
                id: ActivityIdentifier.bagAdded,
                entryID: Identifier.bag,
                title: "Bag",
                kind: .added,
                date: ReferenceDate.created
            ),
            activity(
                id: ActivityIdentifier.plantAdded,
                entryID: Identifier.plant,
                title: "Plant",
                kind: .added,
                date: ReferenceDate.created
            ),
            activity(
                id: ActivityIdentifier.longTitleAdded,
                entryID: Identifier.longTitle,
                title: "Small wooden chair that moved through different rooms",
                kind: .added,
                date: ReferenceDate.created
            )
        ]
    }

    private static func additionalUpdatedActivity() -> [EntryActivity] {
        [
            activity(
                id: ActivityIdentifier.walletUpdated,
                entryID: Identifier.wallet,
                title: "Wallet",
                kind: .updated,
                date: ReferenceDate.current
            ),
            activity(
                id: ActivityIdentifier.bagUpdated,
                entryID: Identifier.bag,
                title: "Bag",
                kind: .updated,
                date: ReferenceDate.current
            ),
            activity(
                id: ActivityIdentifier.plantUpdated,
                entryID: Identifier.plant,
                title: "Plant",
                kind: .updated,
                date: ReferenceDate.current
            ),
            activity(
                id: ActivityIdentifier.longTitleUpdated,
                entryID: Identifier.longTitle,
                title: "Small wooden chair that moved through different rooms",
                kind: .updated,
                date: ReferenceDate.current
            )
        ]
    }

    private static func activity(
        id: String,
        entryID: String,
        title: String,
        kind: EntryActivityKind,
        date: Date
    ) -> EntryActivity {
        .init(summary: .init(
            entryID: uuid(entryID),
            title: title,
            kind: kind,
            date: date,
            id: uuid(id)
        ))
    }
}
