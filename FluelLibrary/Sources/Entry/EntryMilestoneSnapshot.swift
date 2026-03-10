import Foundation
import SwiftData

/// Upcoming milestone derived from one active entry.
public struct EntryMilestoneSnapshot: Equatable, Sendable {
    public let entryID: UUID
    public let title: String
    public let milestoneDate: Date
    public let daysRemaining: Int
    public let milestoneText: String
    public let isApproximate: Bool

    public init(
        entryID: UUID,
        title: String,
        milestoneDate: Date,
        daysRemaining: Int,
        milestoneText: String,
        isApproximate: Bool
    ) {
        self.entryID = entryID
        self.title = title
        self.milestoneDate = milestoneDate
        self.daysRemaining = daysRemaining
        self.milestoneText = milestoneText
        self.isApproximate = isApproximate
    }
}

/// Query helpers that derive upcoming yearly milestones for active entries.
public enum EntryMilestoneSnapshotQuery {
    public static func upcomingActiveMilestones(
        context: ModelContext,
        referenceDate: Date = .now,
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent,
        limit: Int = 3
    ) throws -> [EntryMilestoneSnapshot] {
        upcomingActiveMilestones(
            entries: try EntryRepository.fetchActiveEntries(
                context: context,
                calendar: calendar
            ),
            referenceDate: referenceDate,
            locale: locale,
            calendar: calendar,
            limit: limit
        )
    }

    public static func upcomingActiveMilestones(
        entries: [Entry],
        referenceDate: Date = .now,
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent,
        limit: Int = 3
    ) -> [EntryMilestoneSnapshot] {
        entries
            .filter { entry in
                entry.isArchived == false
            }
            .compactMap { entry in
                snapshot(
                    for: entry,
                    referenceDate: referenceDate,
                    locale: locale,
                    calendar: calendar
                )
            }
            .sorted { lhs, rhs in
                if lhs.daysRemaining != rhs.daysRemaining {
                    return lhs.daysRemaining < rhs.daysRemaining
                }

                if lhs.milestoneDate != rhs.milestoneDate {
                    return lhs.milestoneDate < rhs.milestoneDate
                }

                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
            .prefix(limit)
            .map(\.self)
    }
}

private extension EntryMilestoneSnapshotQuery {
    static func snapshot(
        for entry: Entry,
        referenceDate: Date,
        locale: Locale,
        calendar: Calendar
    ) -> EntryMilestoneSnapshot? {
        guard let startDate = entry.startComponents.earliestDate(
            calendar: calendar
        ) else {
            return nil
        }

        let elapsedSnapshot = EntryElapsedSnapshot(
            startComponents: entry.startComponents,
            referenceDate: referenceDate,
            calendar: calendar
        )
        let targetYears = max(elapsedSnapshot.years + 1, 1)
        guard let milestoneDate = calendar.date(
            byAdding: .year,
            value: targetYears,
            to: startDate
        ) else {
            return nil
        }

        let milestoneSnapshot = EntryElapsedSnapshot(
            startComponents: entry.startComponents,
            referenceDate: milestoneDate,
            calendar: calendar
        )
        let startOfReferenceDay = calendar.startOfDay(for: referenceDate)
        let startOfMilestoneDay = calendar.startOfDay(for: milestoneDate)
        let daysRemaining = max(
            calendar.dateComponents(
                [.day],
                from: startOfReferenceDay,
                to: startOfMilestoneDay
            ).day ?? 0,
            0
        )

        return .init(
            entryID: entry.id,
            title: entry.title,
            milestoneDate: milestoneDate,
            daysRemaining: daysRemaining,
            milestoneText: EntryFormatting.primaryElapsedText(
                for: milestoneSnapshot,
                locale: locale
            ),
            isApproximate: entry.startPrecision != .day
        )
    }
}
