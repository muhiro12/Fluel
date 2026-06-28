import Foundation

/// Validation errors for entry creation and editing inputs.
public enum EntryValidationError: Equatable, LocalizedError, Sendable {
    case emptyTitle
    case futureStart

    public var errorDescription: String? {
        switch self {
        case .emptyTitle:
            EntryLocalization.string("Entry title must not be empty.")
        case .futureStart:
            EntryLocalization.string("Entry start must be today or earlier.")
        }
    }
}
