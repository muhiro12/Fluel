import Foundation
import Testing

import FluelLibrary

struct FluelLinkOperationsTests {
    @Test
    func destinationLinksRoundTripThroughCustomScheme() {
        for destination in FluelLinkDestination.allCases {
            let url = FluelLinkOperations.url(for: .destination(destination))

            #expect(url.scheme == FluelLinkOperations.scheme)
            #expect(FluelLinkOperations.parse(url) == .supported(.destination(destination)))
        }
    }

    @Test
    func unsupportedURLsAreRejected() throws {
        let url = try #require(URL(string: "fluel://unsupported"))

        #expect(FluelLinkOperations.parse(url) == .unsupported)
    }
}
