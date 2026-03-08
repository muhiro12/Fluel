import FluelLibrary
import SwiftData
import SwiftUI
import WidgetKit

private struct LeadEntryWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: EntryWidgetSnapshot?
}

private struct LeadEntryWidgetProvider: TimelineProvider {
    func placeholder(
        in context: Context
    ) -> LeadEntryWidgetEntry {
        .init(
            date: .now,
            snapshot: FluelSampleData.placeholderWidgetSnapshot()
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping @Sendable (LeadEntryWidgetEntry) -> Void
    ) {
        completion(
            .init(
                date: .now,
                snapshot: liveSnapshot() ?? FluelSampleData.placeholderWidgetSnapshot()
            )
        )
    }

    func getTimeline(
        in context: Context,
        completion: @escaping @Sendable (Timeline<LeadEntryWidgetEntry>) -> Void
    ) {
        let entry = LeadEntryWidgetEntry(
            date: .now,
            snapshot: liveSnapshot()
        )
        let refreshDate = Calendar.autoupdatingCurrent.nextDate(
            after: .now,
            matching: .init(hour: 0, minute: 5),
            matchingPolicy: .nextTime
        ) ?? .now.addingTimeInterval(21_600) // swiftlint:disable:this no_magic_numbers

        completion(
            .init(
                entries: [entry],
                policy: .after(refreshDate)
            )
        )
    }

    private func liveSnapshot() -> EntryWidgetSnapshot? {
        do {
            let container = try ModelContainerFactory.shared()

            return try EntryWidgetSnapshotQuery.snapshot(
                context: container.mainContext
            )
        } catch {
            assertionFailure("Widget failed to load shared snapshot: \(error)")
            return nil
        }
    }
}

private struct LeadEntryWidgetView: View {
    @Environment(\.widgetFamily) private var family

    let entry: LeadEntryWidgetEntry

    var body: some View {
        Group {
            if let snapshot = entry.snapshot {
                snapshotView(snapshot)
            } else {
                emptyView
            }
        }
        .containerBackground(.background, for: .widget)
    }

    @ViewBuilder
    private func snapshotView(
        _ snapshot: EntryWidgetSnapshot
    ) -> some View {
        switch family {
        case .systemMedium:
            mediumSnapshotView(snapshot)
        default:
            smallSnapshotView(snapshot)
        }
    }

    private func smallSnapshotView(
        _ snapshot: EntryWidgetSnapshot
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(snapshot.title)
                .font(.headline.weight(.medium))
                .lineLimit(2)

            Spacer(minLength: 0)

            Text(snapshot.primaryText)
                .font(.title3.weight(.semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text(snapshot.startText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Text(
                EntryFormatting.activeCountText(
                    snapshot.activeCount
                )
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
    }

    private func mediumSnapshotView(
        _ snapshot: EntryWidgetSnapshot
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 12) {
                Text(snapshot.title)
                    .font(.headline.weight(.medium))
                    .lineLimit(2)

                Text(snapshot.primaryText)
                    .font(.title2.weight(.semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(snapshot.startText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Spacer(minLength: 0)

                if let mostRecentlyArchivedTitle = snapshot.mostRecentlyArchivedTitle {
                    secondaryBadge(
                        widgetRecentlyArchivedText(
                            for: mostRecentlyArchivedTitle
                        )
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            VStack(alignment: .leading, spacing: 10) {
                mediumMetricGrid(snapshot)

                if let upcomingMilestone = snapshot.upcomingMilestone {
                    highlightCard(
                        title: widgetUpcomingTitle,
                        headline: upcomingMilestone.title,
                        detail: widgetMilestoneDetail(upcomingMilestone)
                    )
                }

                if let recentActivity = snapshot.recentActivity {
                    highlightCard(
                        title: widgetRecentTitle,
                        headline: recentActivity.title,
                        detail: widgetActivityDetail(recentActivity)
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
    }

    private var emptyView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(widgetEmptyTitle)
                .font(.headline.weight(.medium))

            Text(widgetEmptyBody)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
    }

    private func mediumMetricGrid(
        _ snapshot: EntryWidgetSnapshot
    ) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                metricCard(
                    value: "\(snapshot.activeCount)",
                    label: widgetActiveMetricLabel
                )
                metricCard(
                    value: "\(snapshot.archivedCount)",
                    label: widgetArchivedMetricLabel
                )
            }

            HStack(spacing: 8) {
                metricCard(
                    value: "\(snapshot.activeWithNotesCount)",
                    label: widgetNotesMetricLabel
                )
                metricCard(
                    value: "\(snapshot.activeWithPhotosCount)",
                    label: widgetPhotosMetricLabel
                )
            }
        }
    }

    private func metricCard(
        value: String,
        label: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.headline.weight(.semibold))

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func highlightCard(
        title: String,
        headline: String,
        detail: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text(headline)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)

            Text(detail)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func secondaryBadge(
        _ text: String
    ) -> some View {
        Text(text)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.fill.tertiary, in: Capsule())
    }

    private var widgetEmptyTitle: String {
        localized(
            english: "Nothing yet",
            japanese: "まだありません"
        )
    }

    private var widgetEmptyBody: String {
        localized(
            english: "Add an entry in Fluel to quietly keep time with it.",
            japanese: "Fluel で記録を追加すると、その時間が静かに見えてきます。"
        )
    }

    private var widgetActiveMetricLabel: String {
        localized(
            english: "Active",
            japanese: "記録中"
        )
    }

    private var widgetArchivedMetricLabel: String {
        localized(
            english: "Archived",
            japanese: "保管済み"
        )
    }

    private var widgetNotesMetricLabel: String {
        localized(
            english: "Notes",
            japanese: "メモあり"
        )
    }

    private var widgetPhotosMetricLabel: String {
        localized(
            english: "Photos",
            japanese: "写真あり"
        )
    }

    private var widgetUpcomingTitle: String {
        localized(
            english: "Upcoming",
            japanese: "次の節目"
        )
    }

    private var widgetRecentTitle: String {
        localized(
            english: "Recent",
            japanese: "最近の動き"
        )
    }

    private func widgetRecentlyArchivedText(
        for title: String
    ) -> String {
        localized(
            english: "Recently archived: \(title)",
            japanese: "最近保管: \(title)"
        )
    }

    private func widgetMilestoneDetail(
        _ milestone: EntryMilestoneSnapshot
    ) -> String {
        let approximateSuffix = milestone.isApproximate
            ? localized(
                english: "Approximate start",
                japanese: "開始時期は概算"
            )
            : nil

        let base: String
        if milestone.daysRemaining == 0 {
            base = localized(
                english: "\(milestone.milestoneText) today",
                japanese: "今日で\(milestone.milestoneText)"
            )
        } else {
            base = localized(
                english: "\(milestone.milestoneText) in \(milestone.daysRemaining) days",
                japanese: "あと\(milestone.daysRemaining)日で\(milestone.milestoneText)"
            )
        }

        guard let approximateSuffix else {
            return base
        }

        return "\(base) · \(approximateSuffix)"
    }

    private func widgetActivityDetail(
        _ activity: EntryActivitySnapshot
    ) -> String {
        let timestamp = activity.timestamp.formatted(
            date: .abbreviated,
            time: .omitted
        )

        return "\(widgetActivityKind(activity.kind)) · \(timestamp)"
    }

    private func widgetActivityKind(
        _ kind: EntryActivityKind
    ) -> String {
        switch kind {
        case .added:
            return localized(
                english: "Added",
                japanese: "追加"
            )
        case .updated:
            return localized(
                english: "Updated",
                japanese: "更新"
            )
        case .archived:
            return localized(
                english: "Archived",
                japanese: "保管"
            )
        }
    }

    private func localized(
        english: String,
        japanese: String
    ) -> String {
        let languageIdentifier = Locale.autoupdatingCurrent.language.languageCode?.identifier ?? Locale.autoupdatingCurrent.identifier

        if languageIdentifier.hasPrefix("ja") {
            return japanese
        }

        return english
    }
}

struct LeadEntryWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: FluelWidgetConstants.kind,
            provider: LeadEntryWidgetProvider()
        ) { entry in
            LeadEntryWidgetView(entry: entry)
        }
        .configurationDisplayName("Fluel")
        .description(widgetDescription)
        .supportedFamilies([.systemSmall, .systemMedium])
    }

    private var widgetDescription: String {
        let languageIdentifier = Locale.autoupdatingCurrent.language.languageCode?.identifier ?? Locale.autoupdatingCurrent.identifier

        if languageIdentifier.hasPrefix("ja") {
            return "いちばん長く一緒にいる記録と、その周辺の状況を表示します。"
        }

        return "Shows your longest-running entry and nearby dashboard highlights."
    }
}

@main
struct FluelWidgetBundle: WidgetBundle {
    var body: some Widget {
        LeadEntryWidget()
    }
}
