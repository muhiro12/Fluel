//
//  EntryTitleSection.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import MHUI
import SwiftUI

struct EntryTitleSection: View {
    @Binding var title: String

    var body: some View {
        Section {
            TextField("Thing or place", text: $title)
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
                .mhInputChrome()
        } header: {
            MHSectionHeader("Entry")
        }
    }
}
