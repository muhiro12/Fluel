//
//  FluelRoute.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import FluelLibrary
import Foundation

enum FluelRoute: Hashable, Identifiable {
    case entries
    case dashboard
    case timeline
    case milestones
    case presets
    case archive

    static let overviewRoutes: [Self] = [
        .dashboard,
        .timeline,
        .milestones
    ]

    static let supportingRoutes: [Self] = [
        .archive,
        .presets
    ]

    var id: Self {
        self
    }

    var title: LocalizedStringResource {
        switch self {
        case .entries:
            "Entries"
        case .dashboard:
            "Dashboard"
        case .timeline:
            "Timeline"
        case .milestones:
            "Milestones"
        case .presets:
            "Presets"
        case .archive:
            "Archive"
        }
    }

    var systemImage: String {
        switch self {
        case .entries:
            "list.bullet"
        case .dashboard:
            "rectangle.grid.2x2"
        case .timeline:
            "clock.arrow.circlepath"
        case .milestones:
            "flag"
        case .presets:
            "bookmark"
        case .archive:
            "archivebox"
        }
    }

    init(destination: FluelLinkDestination) {
        switch destination {
        case .entries:
            self = .entries
        case .dashboard:
            self = .dashboard
        case .timeline:
            self = .timeline
        case .milestones:
            self = .milestones
        case .presets:
            self = .presets
        case .archive:
            self = .archive
        }
    }
}
