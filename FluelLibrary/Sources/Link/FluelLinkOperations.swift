import Foundation
import MHPlatformCore

/// Cross-surface link use cases.
public enum FluelLinkOperations {
    /// Product URL scheme.
    public static let scheme = "fluel"

    /// Builds a URL for a supported Fluel link.
    public static func url(for link: FluelLink) -> URL {
        codec.url(for: link, transport: .customScheme) ?? fallbackURL(for: link)
    }

    /// Parses an incoming URL into a supported Fluel link.
    public static func parse(_ url: URL) -> FluelLinkParseResult {
        guard let link = codec.parse(url) else {
            return .unsupported
        }

        return .supported(link)
    }
}

private extension FluelLinkOperations {
    static let codec = MHDeepLinkCodec<FluelLink>(
        configuration: .init(
            customScheme: scheme,
            preferredUniversalLinkHost: "",
            allowedUniversalLinkHosts: [],
            universalLinkPathPrefix: "",
            preferredTransport: .customScheme
        )
    )

    static func fallbackURL(for link: FluelLink) -> URL {
        switch link {
        case .destination(let destination):
            URL(string: "\(scheme)://\(destination.rawValue)") ?? URL(fileURLWithPath: "/")
        }
    }
}
