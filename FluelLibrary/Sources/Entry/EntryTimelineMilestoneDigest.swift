import Foundation

/// Upcoming milestone digest scoped to the currently visible timeline entries.
public struct EntryTimelineMilestoneDigest: Equatable, Sendable {
    public let visibleEntryCount: Int
    public let milestoneCount: Int
    public let approximateCount: Int
    public let milestones: [EntryMilestoneSnapshot]

    public init(
        visibleEntryCount: Int,
        milestoneCount: Int,
        approximateCount: Int,
        milestones: [EntryMilestoneSnapshot]
    ) {
        self.visibleEntryCount = visibleEntryCount
        self.milestoneCount = milestoneCount
        self.approximateCount = approximateCount
        self.milestones = milestones
    }
}

/// Query helpers that derive timeline-scoped milestone highlights.
public enum EntryTimelineMilestoneDigestQuery {
    public static func digest(
        entries: [Entry],
        visibleActivity: [EntryActivitySnapshot],
        referenceDate: Date = .now,
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent,
        limit: Int = 3
    ) -> EntryTimelineMilestoneDigest {
        let visibleIDs = Set(visibleActivity.map(\.entryID))
        let visibleEntries = entries.filter { entry in
            visibleIDs.contains(entry.id)
        }
        let activeVisibleEntries = visibleEntries.filter { entry in
            entry.isArchived == false
        }
        let milestones = EntryMilestoneSnapshotQuery.upcomingActiveMilestones(
            entries: activeVisibleEntries,
            referenceDate: referenceDate,
            locale: locale,
            calendar: calendar,
            limit: limit
        )

        return .init(
            visibleEntryCount: visibleEntries.count,
            milestoneCount: milestones.count,
            approximateCount: milestones.count(where: \.isApproximate),
            milestones: milestones
        )
    }
}
