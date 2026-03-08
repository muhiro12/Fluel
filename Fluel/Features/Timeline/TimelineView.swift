import FluelLibrary
import MHUI
import SwiftData
import SwiftUI

struct ActivityTimelineView: View {
    @Query
    private var entries: [Entry]

    let onAdd: () -> Void

    private var sections: [EntryActivityTimelineSection] {
        EntryActivityTimelineSectionQuery.sections(
            entries: entries
        )
    }

    private var entryLookup: [UUID: Entry] {
        Dictionary(
            uniqueKeysWithValues: entries.map { entry in
                (
                    entry.id,
                    entry
                )
            }
        )
    }

    var body: some View {
        Group {
            if entries.isEmpty {
                emptyState
            } else {
                timelineList
            }
        }
        .mhScreen(
            title: Text(FluelCopy.timeline()),
            subtitle: Text(FluelCopy.timelineScreenSubtitle())
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onAdd) {
                    Label(
                        FluelCopy.add(),
                        systemImage: "plus"
                    )
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(
                FluelCopy.timelineEmptyTitle(),
                systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90"
            )
        } description: {
            Text(FluelCopy.timelineEmptyBody())
        } actions: {
            Button(
                FluelCopy.addFirstEntry(),
                action: onAdd
            )
            .buttonStyle(.mhPrimary)
        }
        .mhEmptyStateLayout()
        .mhSurfaceInset()
        .mhSurface(role: .muted)
    }

    private var timelineList: some View {
        List {
            ForEach(sections, id: \.monthStart) { section in
                Section(section.title) {
                    ForEach(section.items, id: \.entryID) { item in
                        if let entry = entryLookup[item.entryID] {
                            NavigationLink {
                                EntryDetailView(entry: entry)
                            } label: {
                                TimelineActivityRow(activity: item)
                            }
                        } else {
                            TimelineActivityRow(activity: item)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private struct TimelineActivityRow: View {
    let activity: EntryActivitySnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(activity.title)
                .mhRowTitle()

            HStack(spacing: 8) {
                Text(
                    FluelCopy.entryActivityKind(activity.kind)
                )
                .font(.caption.weight(.semibold))
                .foregroundStyle(activityColor)

                Text(activityTimestampText)
                    .mhTextStyle(
                        .metadata,
                        colorRole: .secondaryText
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    private var activityColor: Color {
        switch activity.kind {
        case .added:
            return .green
        case .updated:
            return .orange
        case .archived:
            return .secondary
        }
    }

    private var activityTimestampText: String {
        switch activity.kind {
        case .added:
            return EntryFormatting.createdOnText(activity.timestamp)
        case .updated:
            return EntryFormatting.updatedOnText(activity.timestamp)
        case .archived:
            return EntryFormatting.archivedOnText(activity.timestamp)
        }
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    NavigationStack {
        ActivityTimelineView(
            onAdd: {}
        )
    }
    .fluelAppStyle()
}
