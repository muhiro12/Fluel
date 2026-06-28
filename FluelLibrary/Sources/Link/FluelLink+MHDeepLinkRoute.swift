import Foundation
import MHPlatformCore

extension FluelLink: MHDeepLinkRoute {
    private enum LinkPathComponentCount {
        static let destination = 1
    }

    public var deepLinkDescriptor: MHDeepLinkDescriptor {
        switch self {
        case .destination(let destination):
            .init(pathComponents: [destination.rawValue])
        }
    }

    public init?(deepLinkDescriptor: MHDeepLinkDescriptor) {
        let pathComponents = deepLinkDescriptor.pathComponents

        guard pathComponents.count == LinkPathComponentCount.destination,
              let destination = FluelLinkDestination(rawValue: pathComponents[0]) else {
            return nil
        }

        self = .destination(destination)
    }
}
