import Foundation

/// Stable values for one user-visible entry activity event.
public struct EntryActivitySummary: Equatable, Identifiable, Sendable {
    /// Stable activity identifier.
    public let id: UUID
    /// Entry identifier.
    public let entryID: UUID
    /// Entry title at the time the activity occurred.
    public let title: String
    /// Activity kind.
    public let kind: EntryActivityKind
    /// Activity date.
    public let date: Date

    /// Creates an activity summary.
    public init(
        entryID: UUID,
        title: String,
        kind: EntryActivityKind,
        date: Date,
        id: UUID = .init()
    ) {
        self.id = id
        self.entryID = entryID
        self.title = title
        self.kind = kind
        self.date = date
    }
}
