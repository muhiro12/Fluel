//
//  FluelDestinationIntentValue.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import AppIntents

enum FluelDestinationIntentValue: String, AppEnum {
    case entries
    case dashboard
    case timeline
    case milestones
    case presets
    case archive

    static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource("Destination", table: "AppIntents")
    )

    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .entries: DisplayRepresentation(title: LocalizedStringResource("Entries", table: "AppIntents")),
        .dashboard: DisplayRepresentation(title: LocalizedStringResource("Dashboard", table: "AppIntents")),
        .timeline: DisplayRepresentation(title: LocalizedStringResource("Timeline", table: "AppIntents")),
        .milestones: DisplayRepresentation(title: LocalizedStringResource("Milestones", table: "AppIntents")),
        .presets: DisplayRepresentation(title: LocalizedStringResource("Presets", table: "AppIntents")),
        .archive: DisplayRepresentation(title: LocalizedStringResource("Archive", table: "AppIntents"))
    ]

    var route: FluelRoute? {
        switch self {
        case .entries:
            nil
        case .dashboard:
            .dashboard
        case .timeline:
            .timeline
        case .milestones:
            .milestones
        case .presets:
            .presets
        case .archive:
            .archive
        }
    }
}
