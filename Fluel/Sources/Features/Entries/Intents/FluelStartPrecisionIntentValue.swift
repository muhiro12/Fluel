//
//  FluelStartPrecisionIntentValue.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import AppIntents
import FluelLibrary

enum FluelStartPrecisionIntentValue: String, AppEnum {
    case day
    case month
    case year

    static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource("Precision", table: "AppIntents")
    )

    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .day: DisplayRepresentation(title: LocalizedStringResource("Day", table: "AppIntents")),
        .month: DisplayRepresentation(title: LocalizedStringResource("Month", table: "AppIntents")),
        .year: DisplayRepresentation(title: LocalizedStringResource("Year", table: "AppIntents"))
    ]

    var startPrecision: StartPrecision {
        switch self {
        case .day:
            .day
        case .month:
            .month
        case .year:
            .year
        }
    }
}
