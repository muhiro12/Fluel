//
//  FluelShortcuts.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import AppIntents

struct FluelShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateEntryIntent(),
            phrases: [
                "Create an entry in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Create Entry", table: "AppIntents"),
            systemImageName: "plus.circle"
        )

        AppShortcut(
            intent: CheckTimeTogetherIntent(),
            phrases: [
                "Check time together in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Time Together", table: "AppIntents"),
            systemImageName: "clock"
        )

        AppShortcut(
            intent: OpenFluelIntent(),
            phrases: [
                "Open \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Open Fluel", table: "AppIntents"),
            systemImageName: "rectangle.grid.2x2"
        )

        AppShortcut(
            intent: OpenFluelDestinationIntent(),
            phrases: [
                "Open \(\.$destination) in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Open Fluel Destination", table: "AppIntents"),
            systemImageName: "arrow.turn.down.right"
        )
    }
}
