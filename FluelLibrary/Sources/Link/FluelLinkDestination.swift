import Foundation

/// Major Fluel destinations that can be opened from a system surface.
public enum FluelLinkDestination: String, CaseIterable, Codable, Identifiable, Sendable {
    case entries
    case dashboard
    case timeline
    case milestones
    case presets
    case archive

    /// Stable destination identity.
    public var id: String {
        rawValue
    }

    /// User-facing destination title.
    public var title: LocalizedStringResource {
        switch self {
        case .entries:
            "Entries"
        case .dashboard:
            "Dashboard"
        case .timeline:
            "Timeline"
        case .milestones:
            "Milestones"
        case .presets:
            "Presets"
        case .archive:
            "Archive"
        }
    }
}
