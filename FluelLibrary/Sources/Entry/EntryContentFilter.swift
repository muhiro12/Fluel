import Foundation

/// Supported content filters for entry lists.
public enum EntryContentFilterMode: String, CaseIterable, Sendable {
    case all
    case withNote
    case withPhoto
}

/// Shared content filtering helpers for entry collections.
public enum EntryContentFilter {
    public static func filter(
        _ entries: [Entry],
        mode: EntryContentFilterMode
    ) -> [Entry] {
        guard mode != .all else {
            return entries
        }

        return entries.filter { entry in
            matches(
                entry,
                mode: mode
            )
        }
    }
}

private extension EntryContentFilter {
    static func matches(
        _ entry: Entry,
        mode: EntryContentFilterMode
    ) -> Bool {
        switch mode {
        case .all:
            return true
        case .withNote:
            return entry.note?.isEmpty == false
        case .withPhoto:
            return entry.photoData?.isEmpty == false
        }
    }
}
