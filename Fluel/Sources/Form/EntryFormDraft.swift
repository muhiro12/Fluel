import FluelLibrary
import PhotosUI
import SwiftUI
import UIKit

struct EntryFormDraft {
    var title: String
    var precision: EntryDatePrecision
    var selectedDate: Date
    var year: Int
    var month: Int
    var note: String
    var photoData: Data?

    let currentDate: Date
    let calendar: Calendar
    let initialInput: EntryFormInput

    init(
        mode: EntryFormView.Mode,
        prefilledInput: EntryFormInput? = nil,
        currentDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.currentDate = currentDate
        self.calendar = calendar

        let resolvedEntry: Entry?
        let createInput: EntryFormInput?

        switch mode {
        case .create:
            resolvedEntry = nil
            createInput = prefilledInput
        case let .edit(entry):
            resolvedEntry = entry
            createInput = nil
        }

        let prefilledStartDate = createInput.flatMap { input in
            try? input.resolvedStartComponents(
                referenceDate: currentDate,
                calendar: calendar
            )
            .earliestDate(calendar: calendar)
        }
        let resolvedTitle = resolvedEntry?.title ?? createInput?.title ?? String()
        let resolvedPrecision = resolvedEntry?.startPrecision ?? createInput?.startPrecision ?? .day
        let resolvedYear = resolvedEntry?.startYear ?? createInput?.startYear ?? calendar.component(.year, from: currentDate)
        let resolvedMonth = resolvedEntry?.startMonth ?? createInput?.startMonth ?? calendar.component(.month, from: currentDate)
        let resolvedNote = resolvedEntry?.note ?? createInput?.note ?? String()
        let resolvedPhotoData = resolvedEntry?.photoData ?? createInput?.photoData
        let defaultDate = resolvedEntry?.startComponents.earliestDate(calendar: calendar)
            ?? prefilledStartDate
            ?? currentDate
        let initialYear = resolvedPrecision == .day
            ? calendar.component(.year, from: defaultDate)
            : resolvedYear
        let initialMonth: Int? = switch resolvedPrecision {
        case .day:
            calendar.component(.month, from: defaultDate)
        case .month:
            resolvedMonth
        case .year:
            nil
        }
        let initialDay: Int? = resolvedPrecision == .day
            ? calendar.component(.day, from: defaultDate)
            : nil

        title = resolvedTitle
        precision = resolvedPrecision
        selectedDate = defaultDate
        year = resolvedYear
        month = resolvedMonth
        note = resolvedNote
        photoData = resolvedPhotoData
        initialInput = .init(
            title: resolvedTitle,
            startPrecision: resolvedPrecision,
            startYear: initialYear,
            startMonth: initialMonth,
            startDay: initialDay,
            photoData: resolvedPhotoData,
            note: resolvedNote
        )
    }
}

extension EntryFormDraft {
    var input: EntryFormInput {
        let resolvedDay: Int?

        switch precision {
        case .day:
            resolvedDay = calendar.component(.day, from: selectedDate)
        case .month, .year:
            resolvedDay = nil
        }

        return .init(
            title: title,
            startPrecision: precision,
            startYear: precision == .day
                ? calendar.component(.year, from: selectedDate)
                : year,
            startMonth: precision == .year
                ? nil
                : (precision == .day
                    ? calendar.component(.month, from: selectedDate)
                    : month),
            startDay: resolvedDay,
            photoData: photoData,
            note: note
        )
    }

    var canSave: Bool {
        do {
            _ = try input.resolvedStartComponents(
                referenceDate: currentDate,
                calendar: calendar
            )
            return true
        } catch {
            return false
        }
    }

    var hasUnsavedChanges: Bool {
        input != initialInput
    }

    var yearRange: [Int] {
        let currentYear = calendar.component(.year, from: currentDate)

        return Array((1_900...currentYear).reversed()) // swiftlint:disable:this no_magic_numbers
    }

    var availableMonths: [(value: Int, label: String)] {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        let monthSymbols = formatter.monthSymbols ?? []
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        let maxMonth = year == currentYear ? currentMonth : 12

        return monthSymbols
            .prefix(maxMonth)
            .enumerated()
            .map { offset, name in
                (
                    value: offset + 1,
                    label: name
                )
            }
    }

    var startSectionFooterText: String? {
        guard let startSummaryText else {
            return nil
        }

        return """
        \(startSummaryText)
        \(FluelCopy.knownAs()): \(EntryFormatting.precisionText(for: precision))
        """
    }

    var selectedImage: UIImage? {
        guard let photoData else {
            return nil
        }

        return UIImage(data: photoData)
    }

    var noteFooterText: String {
        guard let countText = EntryFormatting.noteCharacterCountText(note) else {
            return FluelCopy.notePlaceholder()
        }

        return """
        \(FluelCopy.notePlaceholder())
        \(countText)
        """
    }

    mutating func updateSelectedDate(
        _ newValue: Date
    ) {
        selectedDate = newValue
        year = calendar.component(.year, from: newValue)
        month = calendar.component(.month, from: newValue)
    }

    mutating func syncForPrecision() {
        if precision == .day {
            selectedDate = calendar.date(
                from: .init(
                    year: year,
                    month: month,
                    day: 1
                )
            ) ?? currentDate
        }

        if precision == .year {
            month = 1
        } else {
            let currentMonth = calendar.component(.month, from: currentDate)
            let currentYear = calendar.component(.year, from: currentDate)

            if year == currentYear {
                month = min(month, currentMonth)
            }
        }
    }

    mutating func removePhoto() {
        photoData = nil
    }

    mutating func clearNote() {
        note = String()
    }

    mutating func loadPhoto(
        from item: PhotosPickerItem?
    ) async throws {
        guard let item else {
            return
        }

        photoData = try await item.loadTransferable(type: Data.self)
    }
}

private extension EntryFormDraft {
    var startSummaryText: String? {
        guard let startPreviewComponents else {
            return nil
        }

        return EntryFormatting.formStartSummaryText(
            for: startPreviewComponents
        )
    }

    var startPreviewComponents: EntryStartComponents? {
        try? .init(
            precision: precision,
            year: precision == .day
                ? calendar.component(.year, from: selectedDate)
                : year,
            month: precision == .year
                ? nil
                : (precision == .day
                    ? calendar.component(.month, from: selectedDate)
                    : month),
            day: precision == .day
                ? calendar.component(.day, from: selectedDate)
                : nil
        )
    }
}
