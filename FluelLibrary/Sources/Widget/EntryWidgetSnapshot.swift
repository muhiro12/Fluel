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
}

/// Shared widget query helpers that read the lead active entry from the shared store.
public enum EntryWidgetSnapshotQuery {
    public static func snapshot(
        context: ModelContext,
        referenceDate: Date = .now,
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent
    ) throws -> EntryWidgetSnapshot? {
        let activeEntries = try EntryRepository.fetchActiveEntries(
            context: context,
            calendar: calendar
        )

        guard let leadEntry = activeEntries.first else {
            return nil
        }

        let elapsedSnapshot = EntryElapsedSnapshot(
            startComponents: leadEntry.startComponents,
            referenceDate: referenceDate,
            calendar: calendar
        )

        return .init(
            title: leadEntry.title,
            primaryText: EntryFormatting.primaryElapsedText(
                for: elapsedSnapshot,
                locale: locale
            ),
            startText: EntryFormatting.startLabelText(
                for: leadEntry.startComponents,
                locale: locale,
                calendar: calendar
            ),
            activeCount: activeEntries.count
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
            activeCount: 6
        )
    }
}
