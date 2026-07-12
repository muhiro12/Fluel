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
        guard let referenceStart = try? EntryStart(
            date: referenceDate,
            precision: .day,
            timeZone: calendar.timeZone
        ) else {
            return nil
        }

        let calculationCalendar = EntryStart.gregorianCalendar(in: .gmt)
        let normalizedReferenceDate = referenceStart.calculationDate
        let normalizedStartDate = snapshot.start.calculationDate
        guard let milestone = milestone(
            after: normalizedReferenceDate,
            from: normalizedStartDate,
            calendar: calculationCalendar
        ) else {
            return nil
        }

        guard let milestoneStart = try? EntryStart(
            date: milestone.date,
            precision: .day,
            timeZone: .gmt
        ) else {
            return nil
        }

        let daysRemaining = max(
            0,
            calculationCalendar.dateComponents(
                [.day],
                from: normalizedReferenceDate,
                to: milestone.date
            ).day ?? 0
        )

        return .init(
            entryID: snapshot.id,
            title: snapshot.title,
            durationYears: milestone.durationYears,
            date: milestoneStart,
            daysRemaining: daysRemaining,
            isApproximate: snapshot.start.precision.isApproximate
        )
    }

    private static func milestone(
        after referenceDate: Date,
        from startDate: Date,
        calendar: Calendar
    ) -> (date: Date, durationYears: Int)? {
        var durationYears = max(
            1,
            calendar.dateComponents(
                [.year],
                from: startDate,
                to: referenceDate
            ).year ?? 0
        )

        guard var milestoneDate = calendar.date(
            byAdding: .year,
            value: durationYears,
            to: startDate
        ) else {
            return nil
        }

        while milestoneDate < referenceDate {
            durationYears += 1

            guard let nextMilestoneDate = calendar.date(
                byAdding: .year,
                value: durationYears,
                to: startDate
            ) else {
                return nil
            }

            milestoneDate = nextMilestoneDate
        }

        return (milestoneDate, durationYears)
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
