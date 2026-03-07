import Foundation

/// User-known precision for an entry start date.
public enum EntryDatePrecision: String, CaseIterable, Codable, Sendable {
    case day
    case month
    case year
}
