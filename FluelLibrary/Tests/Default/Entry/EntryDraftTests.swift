import Foundation
import Testing

import FluelLibrary

struct EntryDraftTests {
    @Test
    func draftCreatesTrimmedNormalizedMonthInput() throws {
        let calendar = TestDateSupport.calendar
        let draft = EntryDraft(
            title: "  Notebook  ",
            note: "  Ordinary thoughts  ",
            precision: .month,
            month: 5,
            year: 2_025,
            calendar: calendar
        )

        let input = try draft.makeInput(calendar: calendar)

        #expect(input.title == "Notebook")
        #expect(input.note == "Ordinary thoughts")
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

    @Test
    func availableYearsHandlesNonGregorianCurrentYear() {
        var calendar = Calendar(identifier: .japanese)
        calendar.timeZone = TestDateSupport.calendar.timeZone
        let currentDate = TestDateSupport.date(year: 2_026, month: 6, day: 25)
        let currentYear = calendar.component(.year, from: currentDate)
        let draft = EntryDraft(calendar: calendar)

        #expect(currentYear < 1_900)
        #expect(draft.availableYears(currentDate: currentDate, calendar: calendar) == [currentYear])
    }
}
