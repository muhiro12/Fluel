import Foundation
@testable import FluelLibrary
import SwiftData

func makeTestContext() throws -> ModelContext {
    .init(try ModelContainerFactory.inMemory())
}

func isoDate(
    _ string: String
) -> Date {
    guard let date = ISO8601DateFormatter().date(from: string) else {
        preconditionFailure("Invalid ISO-8601 date string: \(string)")
    }

    return date
}

func makeInput( // swiftlint:disable:this function_parameter_count
    title: String,
    precision: EntryDatePrecision,
    year: Int,
    month: Int? = nil,
    day: Int? = nil,
    note: String? = nil
) -> EntryFormInput {
    .init(
        title: title,
        startPrecision: precision,
        startYear: year,
        startMonth: month,
        startDay: day,
        note: note
    )
}
