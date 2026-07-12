import Foundation

/// Reusable starting point for creating an entry.
public struct EntryPreset: Equatable, Identifiable, Sendable {
    private enum DefaultSymbol {
        static let bookmark = "bookmark"
    }

    /// Stable preset identifier.
    public let id: UUID
    /// User-facing preset title.
    public let title: String
    /// SF Symbol name used as a visual cue.
    public let symbolName: String
    /// Relative start.
    public let start: EntryPresetStart
    /// Start precision.
    public let startPrecision: StartPrecision
    /// Optional note.
    public let note: String?
    /// Preset origin.
    public let origin: EntryPresetOrigin
    /// True when the preset is pinned.
    public let isPinned: Bool
    /// True when the preset is the default.
    public let isDefault: Bool
    /// Last use date.
    public let lastUsedAt: Date?

    /// Built-in starter identity when this preset is one of Fluel's stable defaults.
    public var starterIdentity: EntryStarterPreset? {
        guard origin == .starter else {
            return nil
        }

        return .init(id: id)
    }

    /// Localized title for presentation without changing the persisted canonical title.
    public var displayTitle: String {
        starterIdentity?.displayTitle ?? title
    }

    /// Creates an entry preset.
    public init(
        title: String,
        symbolName: String,
        start: EntryPresetStart,
        startPrecision: StartPrecision,
        origin: EntryPresetOrigin,
        id: UUID = UUID(),
        note: String? = nil,
        isPinned: Bool = false,
        isDefault: Bool = false,
        lastUsedAt: Date? = nil
    ) {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.symbolName = Self.normalizedSymbolName(symbolName)
        self.start = start
        self.startPrecision = startPrecision
        self.note = Self.normalizedNote(note)
        self.origin = origin
        self.isPinned = isPinned
        self.isDefault = isDefault
        self.lastUsedAt = lastUsedAt
    }

    private static func normalizedSymbolName(_ symbolName: String) -> String {
        let trimmedSymbolName = symbolName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedSymbolName.isEmpty else {
            return DefaultSymbol.bookmark
        }

        return trimmedSymbolName
    }

    private static func normalizedNote(_ note: String?) -> String? {
        let trimmedNote = note?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let trimmedNote,
              !trimmedNote.isEmpty else {
            return nil
        }

        return trimmedNote
    }
}
