//
//  PreviewSampleData+Drafts.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary

// swiftlint:disable no_magic_numbers number_separator

extension PreviewSampleData {
    static var filledDraft: EntryDraft {
        .init(
            title: "Plant",
            note: "Shares the same light near the kitchen window.",
            precision: .month,
            dayDate: date(year: 2024, month: 3, day: 1),
            month: 3,
            year: 2024
        )
    }

    static var longTextDraft: EntryDraft {
        .init(
            title: "Notebook from the small desk",
            note: """
            Ordinary thoughts, lists, and small reminders gathered across \
            different rooms. The note is intentionally longer so the entry \
            editor preview can show how calm copy wraps.
            """,
            precision: .year,
            dayDate: date(year: 2022, month: 1, day: 1),
            month: 1,
            year: 2022
        )
    }
}

// swiftlint:enable no_magic_numbers number_separator
