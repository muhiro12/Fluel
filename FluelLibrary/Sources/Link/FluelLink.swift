import Foundation

/// A supported Fluel route that can be opened from a system surface.
public enum FluelLink: Equatable, Sendable {
    case destination(FluelLinkDestination)
}
