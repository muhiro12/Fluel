import FluelLibrary
import XCTest

final class FluelLibraryTests: XCTestCase {
    func testPlaceholderModuleName() {
        XCTAssertEqual(FluelLibraryModule.name, "FluelLibrary")
    }
}
