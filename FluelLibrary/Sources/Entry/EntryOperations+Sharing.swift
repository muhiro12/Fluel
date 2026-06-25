import Foundation

public extension EntryOperations {
    /// Returns share-ready text for one entry.
    static func entryShareSummary(
        for snapshot: EntrySnapshot,
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> EntryShareSummary {
        let timeTogether = timeTogether(
            for: snapshot,
            referenceDate: referenceDate,
            calendar: calendar
        )
        var lines = [
            snapshot.title,
            "",
            "Time together: \(timeTogether.primaryText)",
            "Start: \(startLabel(for: snapshot, calendar: calendar))",
            "Precision: \(snapshot.startPrecision.knownAsText)"
        ]

        if let rangeLabel = startRangeLabel(for: snapshot, calendar: calendar) {
            lines.append("Approximate range: \(rangeLabel)")
        }

        if let note = snapshot.note {
            lines.append("Note: \(note)")
        }

        if let archivedAt = snapshot.archivedAt {
            lines.append("Status: Archived")
            lines.append("Archived: \(dateText(archivedAt, calendar: calendar))")
        }

        return .init(
            subject: "Fluel: \(snapshot.title)",
            text: lines.joined(separator: "\n")
        )
    }

    /// Returns share-ready text for a timeline slice.
    static func timelineShareSummary(
        for result: EntryTimelineResult,
        query: EntryTimelineQuery,
        calendar: Calendar = .autoupdatingCurrent
    ) -> EntryShareSummary {
        var lines = [
            "Fluel Timeline",
            "",
            "Scope: \(query.scope.label)",
            "Activity: \(query.filter.label)"
        ]
        let trimmedSearchText = query.searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedSearchText.isEmpty {
            lines.append("Search: \(trimmedSearchText)")
        }

        lines.append(contentsOf: timelineSummaryLines(result.summary))
        lines.append(contentsOf: monthlyTrendLines(result.months, calendar: calendar))
        lines.append(contentsOf: milestoneLines(result.upcomingMilestones, calendar: calendar))

        return .init(
            subject: "Fluel Timeline",
            text: lines.joined(separator: "\n")
        )
    }

    private static func timelineSummaryLines(_ summary: EntryTimelineSummary) -> [String] {
        let visibleActivityText = summary.visibleActivityCount.formatted()
        let totalActivityText = summary.totalActivityCount.formatted()

        return [
            "",
            "Visible activity: \(visibleActivityText) of \(totalActivityText)",
            "Months: \(summary.representedMonthCount.formatted())",
            "Added: \(summary.addedCount.formatted())",
            "Updated: \(summary.updatedCount.formatted())",
            "Archived: \(summary.archivedCount.formatted())"
        ]
    }

    private static func monthlyTrendLines(
        _ months: [EntryTimelineMonth],
        calendar: Calendar
    ) -> [String] {
        guard !months.isEmpty else {
            return []
        }

        let trendLines = months.map { month in
            monthlyTrendLine(month, calendar: calendar)
        }

        return ["", "Monthly trends"] + trendLines
    }

    private static func milestoneLines(
        _ milestones: [EntryMilestone],
        calendar: Calendar
    ) -> [String] {
        guard !milestones.isEmpty else {
            return []
        }

        let shareLines = milestones.map { milestone in
            milestoneLine(milestone, calendar: calendar)
        }

        return ["", "Upcoming milestones"] + shareLines
    }

    private static func monthlyTrendLine(
        _ month: EntryTimelineMonth,
        calendar: Calendar
    ) -> String {
        let monthTitle = monthText(month.monthDate, calendar: calendar)
        let activityCount = activityCountText(month.activity.count)
        let addedCount = month.addedCount.formatted()
        let updatedCount = month.updatedCount.formatted()
        let archivedCount = month.archivedCount.formatted()
        let activityBreakdown = "\(addedCount) added, \(updatedCount) updated, \(archivedCount) archived"

        return "\(monthTitle): \(activityCount) (\(activityBreakdown))"
    }

    private static func milestoneLine(
        _ milestone: EntryMilestone,
        calendar: Calendar
    ) -> String {
        let milestoneDate = dateText(milestone.date, calendar: calendar)
        let suffix = milestone.isApproximate ? " approximate" : ""
        let remainingText = "\(milestone.daysRemainingText)\(suffix)"

        return "\(milestone.title): \(milestone.durationText) on \(milestoneDate) (\(remainingText))"
    }

    private static func activityCountText(_ count: Int) -> String {
        count == 1 ? "1 activity" : "\(count.formatted()) activities"
    }

    private static func monthText(
        _ date: Date,
        calendar: Calendar
    ) -> String {
        formattedDate(date, template: "yMMMM", calendar: calendar)
    }

    private static func dateText(
        _ date: Date,
        calendar: Calendar
    ) -> String {
        formattedDate(date, template: "yMMMd", calendar: calendar)
    }

    private static func formattedDate(
        _ date: Date,
        template: String,
        calendar: Calendar
    ) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = calendar.locale ?? .autoupdatingCurrent
        formatter.timeZone = calendar.timeZone
        formatter.setLocalizedDateFormatFromTemplate(template)

        return formatter.string(from: date)
    }
}
