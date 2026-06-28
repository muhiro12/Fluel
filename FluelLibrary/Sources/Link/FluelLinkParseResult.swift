/// Result of parsing an incoming Fluel URL.
public enum FluelLinkParseResult: Equatable, Sendable {
    case supported(FluelLink)
    case unsupported
}
