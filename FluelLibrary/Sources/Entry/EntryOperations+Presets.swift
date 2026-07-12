import Foundation

public extension EntryOperations {
    private enum PresetOffset {
        static let oneYear = 1
        static let sixMonths = 6
        static let threeMonths = 3
    }

    private struct StarterPresetValue {
        let identity: EntryStarterPreset
        let symbolName: String
        let start: EntryPresetStart
        let precision: StartPrecision
    }

    private static var starterPresetValues: [StarterPresetValue] {
        [
            .init(
                identity: .thisHome,
                symbolName: "house",
                start: .yearsAgo(PresetOffset.oneYear),
                precision: .year
            ),
            .init(
                identity: .wallet,
                symbolName: "wallet.pass",
                start: .yearsAgo(PresetOffset.oneYear),
                precision: .year
            ),
            .init(
                identity: .bag,
                symbolName: "bag",
                start: .monthsAgo(PresetOffset.sixMonths),
                precision: .month
            ),
            .init(
                identity: .shoes,
                symbolName: "shoeprints.fill",
                start: .monthsAgo(PresetOffset.sixMonths),
                precision: .month
            ),
            .init(
                identity: .watch,
                symbolName: "applewatch",
                start: .yearsAgo(PresetOffset.oneYear),
                precision: .year
            ),
            .init(
                identity: .plant,
                symbolName: "leaf",
                start: .monthsAgo(PresetOffset.threeMonths),
                precision: .month
            ),
            .init(
                identity: .notebook,
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
            title: preset.displayTitle,
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

            return lhs.displayTitle.localizedStandardCompare(rhs.displayTitle) == .orderedAscending
        }
    }

    private static func starterPreset(_ value: StarterPresetValue) -> EntryPreset {
        .init(
            title: value.identity.canonicalTitle,
            symbolName: value.symbolName,
            start: value.start,
            startPrecision: value.precision,
            origin: .starter,
            id: value.identity.id
        )
    }
}
