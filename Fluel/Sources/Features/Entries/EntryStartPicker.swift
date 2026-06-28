//
//  EntryStartPicker.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import MHUI
import SwiftUI

struct EntryStartPicker: View {
    @Binding var draft: EntryDraft

    private let calendar = Calendar.autoupdatingCurrent

    var body: some View {
        Section {
            EntryPrecisionPicker(draft: $draft, calendar: calendar)

            EntryStartValuePicker(draft: $draft, calendar: calendar)

            LabeledContent("Known as", value: draft.precision.knownAsText)
            LabeledContent("Start", value: draft.startLabel(calendar: calendar))
        } header: {
            FluelSectionHeader("Start")
        } footer: {
            Text("The start stays exactly as you know it. Month and year starts remain approximate.")
                .mhSectionFooterText()
        }
        .labeledContentStyle(.mhKeyValue)
        .onChange(of: draft.year) {
            draft.clampToPresent(calendar: calendar)
        }
        .onChange(of: draft.month) {
            draft.clampToPresent(calendar: calendar)
        }
    }
}
