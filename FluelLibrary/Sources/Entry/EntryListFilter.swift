import Foundation

/// Filters entry lists by lightweight supporting content.
public enum EntryListFilter: String, CaseIterable, Identifiable, Sendable {
    case all
    case withNote
    case withPhoto

    public var id: Self {
        self
    }

    /// User-facing filter label.
    public var label: String {
        switch self {
        case .all:
            "All"
        case .withNote:
            "With note"
        case .withPhoto:
            "With photo"
        }
    }
}
