//
//  PresetStartOption.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary

enum PresetStartOption: String, CaseIterable, Identifiable {
    case today
    case threeMonthsAgo
    case sixMonthsAgo
    case oneYearAgo
    case twoYearsAgo

    private enum Offset {
        static let threeMonths = 3
        static let sixMonths = 6
        static let oneYear = 1
        static let twoYears = 2
    }

    var id: Self {
        self
    }

    var label: String {
        switch self {
        case .today:
            "Started today"
        case .threeMonthsAgo:
            "3 months ago"
        case .sixMonthsAgo:
            "6 months ago"
        case .oneYearAgo:
            "1 year ago"
        case .twoYearsAgo:
            "2 years ago"
        }
    }

    var start: EntryPresetStart {
        switch self {
        case .today:
            .today
        case .threeMonthsAgo:
            .monthsAgo(Offset.threeMonths)
        case .sixMonthsAgo:
            .monthsAgo(Offset.sixMonths)
        case .oneYearAgo:
            .yearsAgo(Offset.oneYear)
        case .twoYearsAgo:
            .yearsAgo(Offset.twoYears)
        }
    }

    var defaultPrecision: StartPrecision {
        switch self {
        case .today:
            .day
        case .threeMonthsAgo, .sixMonthsAgo:
            .month
        case .oneYearAgo, .twoYearsAgo:
            .year
        }
    }

    static func option(for start: EntryPresetStart) -> Self {
        switch start {
        case .today:
            .today
        case .monthsAgo(let value):
            monthOption(for: value)
        case .yearsAgo(let value):
            yearOption(for: value)
        }
    }

    private static func monthOption(for value: Int) -> Self {
        switch value {
        case Offset.threeMonths:
            .threeMonthsAgo
        case Offset.sixMonths:
            .sixMonthsAgo
        default:
            .today
        }
    }

    private static func yearOption(for value: Int) -> Self {
        switch value {
        case Offset.oneYear:
            .oneYearAgo
        case Offset.twoYears:
            .twoYearsAgo
        default:
            .today
        }
    }
}
