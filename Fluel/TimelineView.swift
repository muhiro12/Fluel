//
//  TimelineView.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import SwiftData
import SwiftUI

struct TimelineView: View {
    @Query(sort: \Entry.updatedAt, order: .reverse)
    private var entries: [Entry]

    @State private var searchText = ""
    @State private var filter = EntryActivityFilter.all
    @State private var scope = EntryTimelineScope.recentYear

    var body: some View {
        List {
            if result.summary.totalActivityCount == 0 {
                TimelineEmptyState()
            } else if result.summary.visibleActivityCount == 0 {
                EntryListFilteredEmptyState(clear: clearSearchAndFilters)
            } else {
                TimelineSummarySection(summary: result.summary)

                if !result.upcomingMilestones.isEmpty {
                    DashboardMilestonesSection(milestones: result.upcomingMilestones)
                }

                ForEach(result.months) { month in
                    TimelineMonthSection(month: month)
                }
            }
        }
        .navigationTitle("Timeline")
        .searchable(text: $searchText, prompt: "Search timeline")
        .toolbar {
            ToolbarItemGroup(placement: .secondaryAction) {
                Menu {
                    Picker("Activity", selection: $filter) {
                        ForEach(EntryActivityFilter.allCases) { filter in
                            Text(filter.label)
                                .tag(filter)
                        }
                    }
                } label: {
                    Label("Activity", systemImage: "line.3.horizontal.decrease.circle")
                }

                Menu {
                    Picker("Scope", selection: $scope) {
                        ForEach(EntryTimelineScope.allCases) { scope in
                            Text(scope.label)
                                .tag(scope)
                        }
                    }
                } label: {
                    Label("Scope", systemImage: "calendar")
                }
            }
        }
    }

    private var result: EntryTimelineResult {
        EntryOperations.timeline(
            from: entries.map(\.snapshot),
            query: .init(searchText: searchText, filter: filter, scope: scope)
        )
    }

    private func clearSearchAndFilters() {
        searchText = ""
        filter = .all
    }
}

#Preview {
    NavigationStack {
        TimelineView()
    }
    .modelContainer(PreviewSampleData.container())
}
