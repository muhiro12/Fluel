import Foundation

public extension EntryOperations {
    /// Returns upcoming yearly milestones for active entries.
    static func upcomingMilestones(
        from snapshots: [EntrySnapshot],
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent,
        limit: Int = 3
    ) -> [EntryMilestone] {
        snapshots
            .filter { snapshot in
                !snapshot.isArchived
            }
            .compactMap { snapshot in
                upcomingMilestone(for: snapshot, referenceDate: referenceDate, calendar: calendar)
            }
            .sorted { lhs, rhs in
                compare(lhs.date, rhs.date, tieBreak: lhs.title < rhs.title)
            }
            .prefix(max(0, limit))
            .map(\.self)
    }

    private static func upcomingMilestone(
        for snapshot: EntrySnapshot,
        referenceDate: Date,
        calendar: Calendar
    ) -> EntryMilestone? {
        let normalizedReferenceDate = calendar.startOfDay(for: referenceDate)
        let normalizedStartDate = calendar.startOfDay(for: snapshot.startDate)
        var durationYears = max(
            1,
            calendar.dateComponents(
                [.year],
                from: normalizedStartDate,
                to: normalizedReferenceDate
            ).year ?? 0
        )

        guard var milestoneDate = calendar.date(
            byAdding: .year,
            value: durationYears,
            to: normalizedStartDate
        ) else {
            return nil
        }

        while milestoneDate < normalizedReferenceDate {
            durationYears += 1

            guard let nextMilestoneDate = calendar.date(
                byAdding: .year,
                value: durationYears,
                to: normalizedStartDate
            ) else {
                return nil
            }

            milestoneDate = nextMilestoneDate
        }

        let daysRemaining = max(
            0,
            calendar.dateComponents(
                [.day],
                from: normalizedReferenceDate,
                to: milestoneDate
            ).day ?? 0
        )

        return .init(
            entryID: snapshot.id,
            title: snapshot.title,
            durationYears: durationYears,
            date: milestoneDate,
            daysRemaining: daysRemaining,
            isApproximate: snapshot.startPrecision.isApproximate
        )
    }

    private static func compare<T: Comparable>(
        _ lhs: T,
        _ rhs: T,
        tieBreak: Bool
    ) -> Bool {
        if lhs == rhs {
            return tieBreak
        }

        return lhs < rhs
    }
}
