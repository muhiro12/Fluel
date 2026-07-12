//
//  EntryEditorErrorAlertsModifier.swift
//  Fluel
//
//  Created by Codex on 2026/07/13.
//

import SwiftUI

struct EntryEditorErrorAlertsModifier: ViewModifier {
    @Binding var isShowingPhotoError: Bool
    @Binding var isShowingSaveError: Bool

    let kind: EntryEditorKind

    func body(content: Content) -> some View {
        content
            .alert(kind.saveErrorTitle, isPresented: $isShowingSaveError) {
                Button("OK", role: .cancel) {
                    isShowingSaveError = false
                }
            }
            .alert("Photo could not be added", isPresented: $isShowingPhotoError) {
                Button("OK", role: .cancel) {
                    isShowingPhotoError = false
                }
            } message: {
                Text("Try again, or choose another photo.")
            }
    }
}
