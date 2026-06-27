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
                "Create an entry in \(.applicationName)",
                "Add an entry with \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Create Entry", table: "AppIntents"),
            systemImageName: "plus.circle"
        )

        AppShortcut(
            intent: CheckTimeTogetherIntent(),
            phrases: [
                "Check time together in \(.applicationName)",
                "How long has this been with me in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Time Together", table: "AppIntents"),
            systemImageName: "clock"
        )

        AppShortcut(
            intent: OpenFluelDestinationIntent(),
            phrases: [
                "Open \(.applicationName)",
                "Open a Fluel screen in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Open Fluel", table: "AppIntents"),
            systemImageName: "rectangle.grid.2x2"
        )
    }
}
