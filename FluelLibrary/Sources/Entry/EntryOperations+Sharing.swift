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
            EntryLocalization.format("share.entry.timeTogether", timeTogether.primaryText),
            EntryLocalization.format(
                "share.entry.start",
                startLabel(for: snapshot, calendar: calendar)
            ),
            EntryLocalization.format("share.entry.precision", snapshot.startPrecision.knownAsText)
        ]

        if let rangeLabel = startRangeLabel(for: snapshot, calendar: calendar) {
            lines.append(EntryLocalization.format("share.entry.approximateRange", rangeLabel))
        }

        if let note = snapshot.note {
            lines.append(EntryLocalization.format("share.entry.note", note))
        }

        if let archivedAt = snapshot.archivedAt {
            lines.append(EntryLocalization.string("share.entry.statusArchived"))
            lines.append(EntryLocalization.format(
                "share.entry.archived",
                dateText(archivedAt, calendar: calendar)
            ))
        }

        return .init(
            subject: EntryLocalization.format("share.entry.subject", snapshot.title),
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
            EntryLocalization.string("Fluel Timeline"),
            "",
            EntryLocalization.format("share.timeline.scope", query.scope.label),
            EntryLocalization.format("share.timeline.activity", query.filter.label)
        ]
        let trimmedSearchText = query.searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedSearchText.isEmpty {
            lines.append(EntryLocalization.format("share.timeline.search", trimmedSearchText))
        }

        lines.append(contentsOf: timelineSummaryLines(result.summary))
        lines.append(contentsOf: monthlyTrendLines(result.months, calendar: calendar))
        lines.append(contentsOf: milestoneLines(result.upcomingMilestones, calendar: calendar))

        return .init(
            subject: EntryLocalization.string("Fluel Timeline"),
            text: lines.joined(separator: "\n")
        )
    }

    private static func timelineSummaryLines(_ summary: EntryTimelineSummary) -> [String] {
        let visibleActivityText = summary.visibleActivityCount.formatted()
        let totalActivityText = summary.totalActivityCount.formatted()

        return [
            "",
            EntryLocalization.format(
                "share.timeline.visibleActivity",
                visibleActivityText,
                totalActivityText
            ),
            EntryLocalization.format(
                "share.timeline.months",
                summary.representedMonthCount.formatted()
            ),
            EntryLocalization.format("share.timeline.added", summary.addedCount.formatted()),
            EntryLocalization.format("share.timeline.updated", summary.updatedCount.formatted()),
            EntryLocalization.format("share.timeline.archived", summary.archivedCount.formatted())
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

        return ["", EntryLocalization.string("Monthly trends")] + trendLines
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

        return ["", EntryLocalization.string("Upcoming milestones")] + shareLines
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
        let activityBreakdown = EntryLocalization.format(
            "share.timeline.activityBreakdown",
            addedCount,
            updatedCount,
            archivedCount
        )

        return EntryLocalization.format(
            "share.timeline.monthLine",
            monthTitle,
            activityCount,
            activityBreakdown
        )
    }

    private static func milestoneLine(
        _ milestone: EntryMilestone,
        calendar: Calendar
    ) -> String {
        let milestoneDate = dateText(milestone.date, calendar: calendar)
        let remainingText = milestone.isApproximate
            ? EntryLocalization.format(
                "share.timeline.remainingApproximate",
                milestone.daysRemainingText
            )
            : milestone.daysRemainingText

        return EntryLocalization.format(
            "share.timeline.milestoneLine",
            milestone.title,
            milestone.durationText,
            milestoneDate,
            remainingText
        )
    }

    private static func activityCountText(_ count: Int) -> String {
        EntryLocalization.duration(
            value: count,
            singularKey: "activity",
            pluralKey: "activities"
        )
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
