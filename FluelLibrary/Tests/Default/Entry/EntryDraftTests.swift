import Foundation
import Testing

import FluelLibrary

struct EntryDraftTests {
    @Test
    func draftCreatesTrimmedNormalizedMonthInput() throws {
        let calendar = TestDateSupport.calendar
        let draft = EntryDraft(
            title: "  Notebook  ",
            precision: .month,
            month: 5,
            year: 2_025,
            calendar: calendar
        )

        let input = try draft.makeInput(calendar: calendar)

        #expect(input.title == "Notebook")
        #expect(input.startDate == TestDateSupport.date(year: 2_025, month: 5, day: 1))
        #expect(input.startPrecision == .month)
    }

    @Test
    func draftRejectsEmptyTitleInput() {
        let calendar = TestDateSupport.calendar
        let draft = EntryDraft(
            title: "   ",
            precision: .year,
            year: 2_025,
            calendar: calendar
        )

        #expect(throws: EntryValidationError.emptyTitle) {
            try draft.makeInput(calendar: calendar)
        }
    }

    @Test
    func draftClampsFutureApproximateComponentsToPresent() {
        let calendar = TestDateSupport.calendar
        var draft = EntryDraft(
            precision: .month,
            month: 12,
            year: 2_027,
            calendar: calendar
        )

        draft.clampToPresent(
            currentDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar
        )

        #expect(draft.year == 2_026)
        #expect(draft.month == 6)
    }
}
