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
        } header: {
            FluelSectionHeader("Entry")
        } footer: {
            Text("Use the name of one thing or place you live with.")
                .mhSectionFooterText()
        }
    }
}
