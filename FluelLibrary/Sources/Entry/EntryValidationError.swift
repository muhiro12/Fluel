import Foundation

/// Validation errors for entry creation and editing inputs.
public enum EntryValidationError: Equatable, LocalizedError, Sendable {
    case emptyTitle

    public var errorDescription: String? {
        switch self {
        case .emptyTitle:
            "Entry title must not be empty."
        }
    }
}
