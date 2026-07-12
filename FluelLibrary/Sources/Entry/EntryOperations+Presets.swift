import Foundation

public extension EntryOperations {
    private enum PresetOffset {
        static let oneYear = 1
        static let sixMonths = 6
        static let threeMonths = 3
    }

    private struct StarterPresetValue {
        let id: String
        let title: String
        let symbolName: String
        let start: EntryPresetStart
        let precision: StartPrecision
    }

    private static var starterPresetValues: [StarterPresetValue] {
        [
            .init(
                id: "11111111-1111-1111-1111-111111111111",
                title: "This home",
                symbolName: "house",
                start: .yearsAgo(PresetOffset.oneYear),
                precision: .year
            ),
            .init(
                id: "22222222-2222-2222-2222-222222222222",
                title: "Wallet",
                symbolName: "wallet.pass",
                start: .yearsAgo(PresetOffset.oneYear),
                precision: .year
            ),
            .init(
                id: "33333333-3333-3333-3333-333333333333",
                title: "Bag",
                symbolName: "bag",
                start: .monthsAgo(PresetOffset.sixMonths),
                precision: .month
            ),
            .init(
                id: "44444444-4444-4444-4444-444444444444",
                title: "Shoes",
                symbolName: "shoeprints.fill",
                start: .monthsAgo(PresetOffset.sixMonths),
                precision: .month
            ),
            .init(
                id: "55555555-5555-5555-5555-555555555555",
                title: "Watch",
                symbolName: "applewatch",
                start: .yearsAgo(PresetOffset.oneYear),
                precision: .year
            ),
            .init(
                id: "66666666-6666-6666-6666-666666666666",
                title: "Plant",
                symbolName: "leaf",
                start: .monthsAgo(PresetOffset.threeMonths),
                precision: .month
            ),
            .init(
                id: "77777777-7777-7777-7777-777777777777",
                title: "Notebook",
                symbolName: "book.closed",
                start: .today,
                precision: .day
            )
        ]
    }

    /// Built-in starter presets.
    static func starterPresets() -> [EntryPreset] {
        starterPresetValues.map(starterPreset)
    }

    /// Creates a draft that uses a preset as a head start.
    static func makeDraft(
        from preset: EntryPreset,
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> EntryDraft {
        let startDate = preset.start.date(referenceDate: referenceDate, calendar: calendar)
        let gregorianCalendar = EntryStart.gregorianCalendar(in: calendar.timeZone)
        let components = gregorianCalendar.dateComponents([.year, .month], from: startDate)

        return .init(
            title: preset.title,
            note: preset.note ?? "",
            precision: preset.startPrecision,
            dayDate: startDate,
            month: components.month,
            year: components.year,
            calendar: calendar
        )
    }

    /// Returns a preset with updated pin state.
    static func pin(
        _ preset: EntryPreset,
        isPinned: Bool
    ) -> EntryPreset {
        .init(
            title: preset.title,
            symbolName: preset.symbolName,
            start: preset.start,
            startPrecision: preset.startPrecision,
            origin: preset.origin,
            id: preset.id,
            note: preset.note,
            isPinned: isPinned,
            isDefault: preset.isDefault,
            lastUsedAt: preset.lastUsedAt
        )
    }

    /// Returns a preset with updated recent-use state.
    static func recordUse(
        of preset: EntryPreset,
        usedAt: Date
    ) -> EntryPreset {
        .init(
            title: preset.title,
            symbolName: preset.symbolName,
            start: preset.start,
            startPrecision: preset.startPrecision,
            origin: preset.origin,
            id: preset.id,
            note: preset.note,
            isPinned: preset.isPinned,
            isDefault: preset.isDefault,
            lastUsedAt: usedAt
        )
    }

    /// Returns presets with one selected default.
    static func setDefaultPreset(
        _ presetID: UUID?,
        in presets: [EntryPreset]
    ) -> [EntryPreset] {
        presets.map { preset in
            .init(
                title: preset.title,
                symbolName: preset.symbolName,
                start: preset.start,
                startPrecision: preset.startPrecision,
                origin: preset.origin,
                id: preset.id,
                note: preset.note,
                isPinned: preset.isPinned,
                isDefault: preset.id == presetID,
                lastUsedAt: preset.lastUsedAt
            )
        }
    }

    /// Returns presets ordered for the preset list.
    static func orderedPresets(_ presets: [EntryPreset]) -> [EntryPreset] {
        presets.sorted { lhs, rhs in
            if lhs.isPinned != rhs.isPinned {
                return lhs.isPinned
            }

            if lhs.lastUsedAt != rhs.lastUsedAt {
                return (lhs.lastUsedAt ?? .distantPast) > (rhs.lastUsedAt ?? .distantPast)
            }

            return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
        }
    }

    private static func starterPreset(_ value: StarterPresetValue) -> EntryPreset {
        .init(
            title: value.title,
            symbolName: value.symbolName,
            start: value.start,
            startPrecision: value.precision,
            origin: .starter,
            id: UUID(uuidString: value.id) ?? UUID()
        )
    }
}
