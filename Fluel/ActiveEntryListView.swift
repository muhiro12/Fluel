//
//  ActiveEntryListView.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import MHUI
import SwiftData
import SwiftUI

struct ActiveEntryListView: View {
    @Query(
        filter: #Predicate<Entry> { entry in
            entry.archivedAt == nil
        },
        sort: \Entry.startDate,
        order: .forward
    )
    private var entries: [Entry]

    let addEntry: () -> Void

    var body: some View {
        Group {
            if entries.isEmpty {
                ActiveEntryEmptyState(addEntry: addEntry)
            } else {
                List(entries) { entry in
                    NavigationLink {
                        EntryDetailView(entry: entry)
                    } label: {
                        EntryRowView(entry: entry)
                    }
                }
            }
        }
    }
}
