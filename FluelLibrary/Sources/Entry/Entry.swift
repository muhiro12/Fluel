import Foundation
import SwiftData

/// One thing or place the user has been living with over time.
@Model
public final class Entry {
    @Attribute(.unique)
    public private(set) var id = UUID()
    public private(set) var title = String()
    public private(set) var startPrecision = EntryDatePrecision.day
    public private(set) var startYear = 2_000
    public private(set) var startMonth: Int?
    public private(set) var startDay: Int?
    @Attribute(.externalStorage)
    public private(set) var photoData: Data?
    public private(set) var note: String?
    public private(set) var archivedAt: Date?
    public private(set) var createdAt = Date(timeIntervalSinceReferenceDate: .zero)
    public private(set) var updatedAt = Date(timeIntervalSinceReferenceDate: .zero)

    private init() {
        // no-op
    }

    public static func create(
        context: ModelContext,
        input: EntryFormInput,
        now: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) throws -> Entry {
        let startComponents = try input.resolvedStartComponents(
            referenceDate: now,
            calendar: calendar
        )
        let entry = Entry()

        context.insert(entry)
        entry.id = UUID()
        entry.apply(
            title: input.trimmedTitle,
            startComponents: startComponents,
            photoData: input.normalizedPhotoData,
            note: input.normalizedNote,
            archivedAt: nil,
            createdAt: now,
            updatedAt: now
        )

        return entry
    }

    public func update(
        input: EntryFormInput,
        now: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) throws {
        let startComponents = try input.resolvedStartComponents(
            referenceDate: now,
            calendar: calendar
        )

        apply(
            title: input.trimmedTitle,
            startComponents: startComponents,
            photoData: input.normalizedPhotoData,
            note: input.normalizedNote,
            archivedAt: archivedAt,
            createdAt: createdAt,
            updatedAt: now
        )
    }

    public func archive(
        now: Date = .now
    ) {
        archivedAt = now
        updatedAt = now
    }

    public func restore(
        now: Date = .now
    ) {
        archivedAt = nil
        updatedAt = now
    }
}

public extension Entry {
    var isArchived: Bool {
        archivedAt != nil
    }

    var startComponents: EntryStartComponents {
        do {
            return try .init(
                precision: startPrecision,
                year: startYear,
                month: startMonth,
                day: startDay
            )
        } catch {
            preconditionFailure("Entry stored invalid start components: \(error)")
        }
    }
}

private extension Entry {
    func apply( // swiftlint:disable:this function_parameter_count
        title: String,
        startComponents: EntryStartComponents,
        photoData: Data?,
        note: String?,
        archivedAt: Date?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.title = title
        startPrecision = startComponents.precision
        startYear = startComponents.year
        startMonth = startComponents.month
        startDay = startComponents.day
        self.photoData = photoData
        self.note = note
        self.archivedAt = archivedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
