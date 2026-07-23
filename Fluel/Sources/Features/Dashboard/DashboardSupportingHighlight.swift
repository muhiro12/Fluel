//
//  DashboardSupportingHighlight.swift
//  Fluel
//
//  Created by Codex on 2026/07/23.
//

import FluelLibrary
import Foundation

enum DashboardSupportingHighlight: Identifiable {
    case archived(
            entryID: UUID,
            title: String,
            date: Date
         )
    case milestone(EntryMilestone)
    case activity(EntryActivitySummary)

    var id: String {
        switch self {
        case .archived(let entryID, _, _):
            "archived-\(entryID.uuidString)"
        case .milestone(let milestone):
            "milestone-\(milestone.id)"
        case .activity(let activity):
            "activity-\(activity.id.uuidString)"
        }
    }

    var systemImage: String {
        switch self {
        case .archived:
            "archivebox"
        case .milestone:
            "calendar.badge.clock"
        case .activity(let activity):
            switch activity.kind {
            case .added:
                "plus"
            case .updated:
                "pencil"
            case .archived:
                "archivebox"
            }
        }
    }
}
