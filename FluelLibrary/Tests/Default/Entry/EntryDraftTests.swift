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
        #expect(input.start == TestDateSupport.start(
            year: 2_025,
            month: 5,
            precision: .month
        ))
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
    func availableYearsUsesGregorianYearWithNonGregorianDisplayCalendar() {
        var calendar = Calendar(identifier: .japanese)
        calendar.timeZone = TestDateSupport.calendar.timeZone
        let currentDate = TestDateSupport.date(year: 2_026, month: 6, day: 25)
        let draft = EntryDraft(calendar: calendar)
        let years = draft.availableYears(
            currentDate: currentDate,
            calendar: calendar
        )

        #expect(years.first == 2_026)
        #expect(years.last == 1_900)
    }

    @Test
    func contentChangesIgnoreInactiveStartComponents() {
        let calendar = TestDateSupport.calendar
        let dayDate = TestDateSupport.date(year: 2_025, month: 5, day: 12)
        let original = EntryDraft(
            title: "Notebook",
            note: "Desk notes",
            precision: .day,
            dayDate: dayDate,
            month: 5,
            year: 2_025,
            calendar: calendar
        )
        let draft = EntryDraft(
            title: original.title,
            note: original.note,
            precision: .day,
            dayDate: dayDate,
            month: 1,
            year: 1_900,
            calendar: calendar
        )

        #expect(!draft.hasContentChanges(comparedTo: original, calendar: calendar))
    }

    @Test
    func contentChangesCompareTheSelectedApproximateStart() {
        let calendar = TestDateSupport.calendar
        let original = EntryDraft(
            title: "Notebook",
            precision: .month,
            month: 5,
            year: 2_025,
            calendar: calendar
        )
        var draft = original

        draft.month = 6

        #expect(draft.hasContentChanges(comparedTo: original, calendar: calendar))
    }

    @Test
    func contentChangesIncludeTextAndPrecision() {
        let calendar = TestDateSupport.calendar
        let original = EntryDraft(
            title: "Notebook",
            note: "Desk notes",
            precision: .year,
            year: 2_025,
            calendar: calendar
        )
        var draft = original

        draft.note = "Shelf notes"
        #expect(draft.hasContentChanges(comparedTo: original, calendar: calendar))

        draft = original
        draft.precision = .month
        #expect(draft.hasContentChanges(comparedTo: original, calendar: calendar))
    }
}
