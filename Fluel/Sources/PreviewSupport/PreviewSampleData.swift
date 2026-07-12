//
//  PreviewSampleData.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import SwiftData

@MainActor
enum PreviewSampleData {
    enum Scenario: String {
        case empty
        case typical
        case dense
        case archive
        case presets
    }

    enum Screen: String {
        case activeEntries
        case dashboard
        case timeline
        case milestones
        case presets
        case archive
        case entryDetail
        case archivedEntryDetail
        case entryEditor

        var defaultScenario: Scenario {
            switch self {
            case .activeEntries,
                 .dashboard,
                 .timeline,
                 .milestones,
                 .entryDetail:
                .dense
            case .presets:
                .presets
            case .archive,
                 .archivedEntryDetail:
                .archive
            case .entryEditor:
                .empty
            }
        }
    }

    private enum Argument {
        static let scenario = "--fluel-ui-preview-scenario"
        static let screen = "--fluel-ui-preview-screen"
    }

    static func container() -> ModelContainer {
        container(for: .typical)
    }

    static func denseContainer() -> ModelContainer {
        container(for: .dense)
    }

    static func emptyContainer() -> ModelContainer {
        container(for: .empty)
    }

    static func archiveContainer() -> ModelContainer {
        container(for: .archive)
    }

    static func presetsContainer() -> ModelContainer {
        container(for: .presets)
    }

    static func container(from arguments: [String]) -> ModelContainer? {
        guard let scenario = scenario(from: arguments) else {
            return nil
        }

        return container(for: scenario)
    }

    static func screen(from arguments: [String]) -> Screen? {
        guard let value = value(after: Argument.screen, in: arguments) else {
            return nil
        }

        return Screen(rawValue: value)
    }

    static func container(for scenario: Scenario) -> ModelContainer {
        let entries: [Entry]
        let activityItems: [EntryActivity]
        let presets: [Preset]
        let defaultSelections: [PresetDefaultSelection]

        switch scenario {
        case .empty:
            entries = []
            activityItems = []
            presets = []
            defaultSelections = []
        case .typical:
            entries = typicalEntries
            activityItems = activity(for: entries)
            presets = samplePresets
            defaultSelections = sampleDefaultSelections
        case .dense:
            entries = denseEntries
            activityItems = activity(for: entries)
            presets = samplePresets
            defaultSelections = sampleDefaultSelections
        case .archive:
            entries = archivedEntries
            activityItems = activity(for: entries)
            presets = samplePresets
            defaultSelections = sampleDefaultSelections
        case .presets:
            entries = []
            activityItems = []
            presets = samplePresets
            defaultSelections = sampleDefaultSelections
        }

        return container(
            entries: entries,
            activity: activityItems,
            presets: presets,
            defaultSelections: defaultSelections
        )
    }

    static func detailContainer(title: String) -> (container: ModelContainer, entry: Entry) {
        let entry = denseEntries.first { entry in
            entry.title == title
        } ?? typicalEntries[0]

        return (
            container: container(
                entries: [entry],
                activity: activity(for: [entry]),
                presets: samplePresets,
                defaultSelections: sampleDefaultSelections
            ),
            entry: entry
        )
    }

    private static func scenario(from arguments: [String]) -> Scenario? {
        guard let value = value(after: Argument.scenario, in: arguments) else {
            return nil
        }

        return Scenario(rawValue: value)
    }

    private static func value(
        after argument: String,
        in arguments: [String]
    ) -> String? {
        guard let argumentIndex = arguments.firstIndex(of: argument) else {
            return nil
        }

        let valueIndex = arguments.index(after: argumentIndex)

        guard arguments.indices.contains(valueIndex) else {
            return nil
        }

        return arguments[valueIndex]
    }
}
