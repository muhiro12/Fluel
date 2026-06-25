import Foundation

/// Archive-related entry operation failures.
public enum EntryArchiveError: Error, Equatable, Sendable {
    /// Active entries must be archived before they can be deleted permanently.
    case activeEntryCannotBeDeleted
}
