import Foundation
@testable import FluelLibrary
import Testing

struct EntryFormInputTests {
    private let calendar = Calendar(identifier: .gregorian)

    @Test
    func duplicatingEntry_copies_stored_fields() throws {
        let context = try makeTestContext()
        let entry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Desk lamp",
                precision: .month,
                year: 2_023,
                month: 9,
                photoData: Data([0x01, 0x02]),
                note: "  Warm light at night.  "
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: calendar
        )

        let result = EntryFormInput(
            duplicating: entry
        )

        #expect(result.title == "Desk lamp")
        #expect(result.startPrecision == .month)
        #expect(result.startYear == 2_023)
        #expect(result.startMonth == 9)
        #expect(result.startDay == nil)
        #expect(result.photoData == Data([0x01, 0x02]))
        #expect(result.note == "Warm light at night.")
    }
}
