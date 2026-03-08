import FluelLibrary
import SwiftUI
import WidgetKit

struct LeadEntryWidgetView: View {
    @Environment(\.widgetFamily)
    private var family

    private let copy = LeadEntryWidgetLocalization()

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
}

private extension LeadEntryWidgetView {
    @ViewBuilder
    func snapshotView(
        _ snapshot: EntryWidgetSnapshot
    ) -> some View {
        switch family {
        case .systemMedium:
            mediumSnapshotView(snapshot)
        default:
            smallSnapshotView(snapshot)
        }
    }

    func smallSnapshotView(
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
                EntryFormatting.activeCountText(snapshot.activeCount)
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
    }

    func mediumSnapshotView(
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
                        copy.recentlyArchivedText(
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
                        title: copy.upcomingTitle,
                        headline: upcomingMilestone.title,
                        detail: copy.milestoneDetail(upcomingMilestone)
                    )
                }

                if let recentActivity = snapshot.recentActivity {
                    highlightCard(
                        title: copy.recentTitle,
                        headline: recentActivity.title,
                        detail: copy.activityDetail(recentActivity)
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
    }

    var emptyView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(copy.emptyTitle)
                .font(.headline.weight(.medium))

            Text(copy.emptyBody)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
    }

    func mediumMetricGrid(
        _ snapshot: EntryWidgetSnapshot
    ) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                metricCard(
                    value: "\(snapshot.activeCount)",
                    label: copy.activeMetricLabel
                )
                metricCard(
                    value: "\(snapshot.archivedCount)",
                    label: copy.archivedMetricLabel
                )
            }

            HStack(spacing: 8) {
                metricCard(
                    value: "\(snapshot.activeWithNotesCount)",
                    label: copy.notesMetricLabel
                )
                metricCard(
                    value: "\(snapshot.activeWithPhotosCount)",
                    label: copy.photosMetricLabel
                )
            }
        }
    }

    func metricCard(
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
        .background(
            .fill.tertiary,
            in: RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
            )
        )
    }

    func highlightCard(
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
        .background(
            .fill.tertiary,
            in: RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
            )
        )
    }

    func secondaryBadge(
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
}
