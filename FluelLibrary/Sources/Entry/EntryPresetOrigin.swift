import Foundation

/// Where a preset comes from.
public enum EntryPresetOrigin: String, Codable, CaseIterable, Identifiable, Sendable {
    case starter
    case custom

    public var id: Self {
        self
    }
}
