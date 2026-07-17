//
//  EntryStartPicker.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import MHUI
import SwiftUI
import TipKit

struct EntryStartPicker: View {
    @Binding var draft: EntryDraft

    private let precisionTip = EntryStartPrecisionTip()
    private let calendar = Calendar.autoupdatingCurrent

    var body: some View {
        Section {
            TipView(precisionTip, arrowEdge: .bottom)

            EntryPrecisionPicker(draft: $draft, calendar: calendar)

            EntryStartValuePicker(draft: $draft, calendar: calendar)

            LabeledContent("Known as", value: draft.precision.knownAsText)
                .labeledContentStyle(.mhKeyValue)

            LabeledContent("Start", value: startLabel)
                .labeledContentStyle(.mhKeyValue)
        } header: {
            MHSectionHeader("Start")
        }
        .onChange(of: draft.precision) {
            precisionTip.invalidate(reason: .actionPerformed)
        }
        .onChange(of: draft.year) {
            draft.clampToPresent(calendar: calendar)
        }
        .onChange(of: draft.month) {
            draft.clampToPresent(calendar: calendar)
        }
    }

    private var startLabel: String {
        guard let label = try? draft.startLabel(calendar: calendar) else {
            assertionFailure("The entry draft contains an invalid start.")
            return ""
        }

        return label
    }
}
