import Foundation
import SwiftData

/// Shared widget constants used by the app and widget extension.
public enum FluelWidgetConstants {
    public static let kind = "com.muhiro12.Fluel.Widget.LivingWith"
}

/// Widget-ready projection for the lead active entry.
public struct EntryWidgetSnapshot: Equatable, Sendable {
    public let title: String
    public let primaryText: String
    public let startText: String
    public let activeCount: Int
    public let archivedCount: Int
    public let activeWithNotesCount: Int
    public let activeWithPhotosCount: Int
    public let mostRecentlyArchivedTitle: String?
    public let upcomingMilestone: EntryMilestoneSnapshot?
    public let recentActivity: EntryActivitySnapshot?
}

/// Shared widget query helpers that read the lead active entry from the shared store.
public enum EntryWidgetSnapshotQuery {
    public static func snapshot(
        context: ModelContext,
        referenceDate: Date = .now,
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent
    ) throws -> EntryWidgetSnapshot? {
        let entries = try EntryRepository.fetchAllEntries(context: context)
        let collectionSnapshot = EntryCollectionSnapshotQuery.snapshot(
            entries: entries,
            referenceDate: referenceDate,
            calendar: calendar
        )
        guard
            let leadTitle = collectionSnapshot.leadActiveTitle,
            let leadStartComponents = collectionSnapshot.leadActiveStartComponents,
            let leadElapsedSnapshot = collectionSnapshot.leadActiveElapsedSnapshot
        else {
            return nil
        }
        let upcomingMilestone = EntryMilestoneSnapshotQuery.upcomingActiveMilestones(
            entries: entries,
            referenceDate: referenceDate,
            locale: locale,
            calendar: calendar,
            limit: 1
        ).first
        let recentActivity = EntryActivitySnapshotQuery.recent(
            entries: entries,
            limit: 1
        ).first

        return .init(
            title: leadTitle,
            primaryText: EntryFormatting.primaryElapsedText(
                for: leadElapsedSnapshot,
                locale: locale
            ),
            startText: EntryFormatting.startLabelText(
                for: leadStartComponents,
                locale: locale,
                calendar: calendar
            ),
            activeCount: collectionSnapshot.activeCount,
            archivedCount: collectionSnapshot.archivedCount,
            activeWithNotesCount: collectionSnapshot.activeWithNotesCount,
            activeWithPhotosCount: collectionSnapshot.activeWithPhotosCount,
            mostRecentlyArchivedTitle: collectionSnapshot.mostRecentlyArchivedTitle,
            upcomingMilestone: upcomingMilestone,
            recentActivity: recentActivity
        )
    }

    public static func placeholder(
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent
    ) -> EntryWidgetSnapshot {
        let startComponents = (try? EntryStartComponents(
            precision: .day,
            year: 2_024,
            month: 3,
            day: 8
        )) ?? (try? EntryStartComponents(
            precision: .year,
            year: 2_024
        ))
        let resolvedStartComponents = startComponents ?? {
            preconditionFailure("Failed to build placeholder widget start components.")
        }()
        let snapshot = EntryElapsedSnapshot(
            startComponents: resolvedStartComponents,
            referenceDate: calendar.date(
                from: .init(
                    year: 2_026,
                    month: 3,
                    day: 8
                )
            ) ?? .now,
            calendar: calendar
        )

        return .init(
            title: "Wallet",
            primaryText: EntryFormatting.primaryElapsedText(
                for: snapshot,
                locale: locale
            ),
            startText: EntryFormatting.startLabelText(
                for: resolvedStartComponents,
                locale: locale,
                calendar: calendar
            ),
            activeCount: 6,
            archivedCount: 1,
            activeWithNotesCount: 3,
            activeWithPhotosCount: 2,
            mostRecentlyArchivedTitle: "Desk lamp",
            upcomingMilestone: .init(
                entryID: UUID(uuidString: "11111111-1111-1111-1111-111111111111") ?? UUID(),
                title: "Wallet",
                milestoneDate: calendar.date(
                    from: .init(
                        year: 2_026,
                        month: 3,
                        day: 8
                    )
                ) ?? .now,
                daysRemaining: 0,
                milestoneText: EntryFormatting.primaryElapsedText(
                    for: snapshot,
                    locale: locale
                ),
                isApproximate: false
            ),
            recentActivity: .init(
                entryID: UUID(uuidString: "22222222-2222-2222-2222-222222222222") ?? UUID(),
                title: "Desk lamp",
                kind: .archived,
                timestamp: calendar.date(
                    from: .init(
                        year: 2_026,
                        month: 2,
                        day: 19
                    )
                ) ?? .now
            )
        )
    }
}
