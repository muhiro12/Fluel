//
//  EntryEditorDiscardConfirmationModifier.swift
//  Fluel
//
//  Created by Codex on 2026/07/13.
//

import SwiftUI

struct EntryEditorDiscardConfirmationModifier: ViewModifier {
    @Binding var isPresented: Bool

    let kind: EntryEditorKind
    let discard: () -> Void

    func body(content: Content) -> some View {
        content.confirmationDialog(
            kind.discardConfirmationTitle,
            isPresented: $isPresented,
            titleVisibility: .visible
        ) {
            Button(role: .destructive, action: discard) {
                kind.discardButtonTitle
            }

            Button("Keep Editing", role: .cancel) {
                isPresented = false
            }
        } message: {
            Text("Unsaved changes will be lost.")
        }
    }
}
