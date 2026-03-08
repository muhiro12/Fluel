import Foundation

/// Input payload used when creating or updating an entry.
public struct EntryFormInput: Equatable, Sendable {
    public var title: String
    public var startPrecision: EntryDatePrecision
    public var startYear: Int
    public var startMonth: Int?
    public var startDay: Int?
    public var photoData: Data?
    public var note: String?

    public init( // swiftlint:disable:this function_parameter_count
        title: String,
        startPrecision: EntryDatePrecision,
        startYear: Int,
        startMonth: Int? = nil,
        startDay: Int? = nil,
        photoData: Data? = nil,
        note: String? = nil
    ) {
        self.title = title
        self.startPrecision = startPrecision
        self.startYear = startYear
        self.startMonth = startMonth
        self.startDay = startDay
        self.photoData = photoData
        self.note = note
    }

    public init(
        duplicating entry: Entry
    ) {
        self.init(
            title: entry.title,
            startPrecision: entry.startPrecision,
            startYear: entry.startYear,
            startMonth: entry.startMonth,
            startDay: entry.startDay,
            photoData: entry.photoData,
            note: entry.note
        )
    }

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var normalizedNote: String? {
        guard let note else {
            return nil
        }

        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedNote.isEmpty {
            return nil
        }

        return trimmedNote
    }

    var normalizedPhotoData: Data? {
        guard let photoData,
              photoData.isEmpty == false else {
            return nil
        }

        return photoData
    }

    public func resolvedStartComponents(
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) throws -> EntryStartComponents {
        guard trimmedTitle.isEmpty == false else {
            throw EntryRepositoryError.emptyTitle
        }

        let components = try EntryStartComponents(
            precision: startPrecision,
            year: startYear,
            month: startMonth,
            day: startDay
        )

        guard components.isInFuture(
            referenceDate: referenceDate,
            calendar: calendar
        ) == false else {
            throw EntryRepositoryError.futureStartDate
        }

        return components
    }
}
