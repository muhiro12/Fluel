import Foundation
import Testing

import FluelLibrary

struct EntryPresetOperationsTests {
    @Test
    func starterPresetsPreserveFamiliarExamples() {
        let presets = EntryOperations.starterPresets()

        #expect(presets.map(\.title) == [
            "This home",
            "Wallet",
            "Bag",
            "Shoes",
            "Watch",
            "Plant",
            "Notebook"
        ])
        #expect(presets.allSatisfy { preset in
            preset.origin == .starter
        })
    }

    @Test
    func presetNormalizesOptionalTextFields() {
        let preset = EntryPreset(
            title: "  Wallet  ",
            symbolName: "  ",
            start: .yearsAgo(1),
            startPrecision: .year,
            origin: .custom,
            note: "  "
        )

        #expect(preset.title == "Wallet")
        #expect(preset.symbolName == "bookmark")
        #expect(preset.note == nil)
    }

    @Test
    func presetCreatesEntryDraftHeadStart() {
        let calendar = TestDateSupport.calendar
        let preset = EntryPreset(
            title: "Plant",
            symbolName: "leaf",
            start: .monthsAgo(3),
            startPrecision: .month,
            origin: .custom,
            note: "Shares the same light."
        )

        let draft = EntryOperations.makeDraft(
            from: preset,
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar
        )

        #expect(draft.title == "Plant")
        #expect(draft.note == "Shares the same light.")
        #expect(draft.precision == .month)
        #expect(draft.month == 3)
        #expect(draft.year == 2_026)
    }

    @Test
    func presetsCanBePinnedDefaultedAndOrdered() {
        let firstUsedAt = TestDateSupport.date(year: 2_026, month: 6, day: 1)
        let secondUsedAt = TestDateSupport.date(year: 2_026, month: 6, day: 2)
        let wallet = EntryPreset(
            title: "Wallet",
            symbolName: "wallet.pass",
            start: .yearsAgo(1),
            startPrecision: .year,
            origin: .custom
        )
        let bag = EntryPreset(
            title: "Bag",
            symbolName: "bag",
            start: .monthsAgo(6),
            startPrecision: .month,
            origin: .custom
        )

        let pinnedWallet = EntryOperations.pin(wallet, isPinned: true)
        let usedBag = EntryOperations.recordUse(of: bag, usedAt: secondUsedAt)
        let usedWallet = EntryOperations.recordUse(of: pinnedWallet, usedAt: firstUsedAt)
        let defaulted = EntryOperations.setDefaultPreset(
            usedBag.id,
            in: [usedWallet, usedBag]
        )
        let clearedDefault = EntryOperations.setDefaultPreset(nil, in: defaulted)
        let ordered = EntryOperations.orderedPresets(defaulted)

        #expect(defaulted.first { preset in preset.id == usedBag.id }?.isDefault == true)
        #expect(clearedDefault.allSatisfy { preset in !preset.isDefault })
        #expect(ordered.map(\.title) == ["Wallet", "Bag"])
    }
}
