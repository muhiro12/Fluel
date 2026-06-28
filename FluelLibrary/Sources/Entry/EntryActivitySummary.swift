import Foundation

/// Dashboard-ready activity derived from an entry snapshot.
public struct EntryActivitySummary: Equatable, Identifiable, Sendable {
    /// Stable activity identifier.
    public let id: String
    /// Entry identifier.
    public let entryID: UUID
    /// Entry title at the time the summary is built.
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
        date: Date
    ) {
        id = "\(entryID.uuidString)-\(kind.rawValue)"
        self.entryID = entryID
        self.title = title
        self.kind = kind
        self.date = date
    }
}
