//
//  EntryPhotoEditorSection.swift
//  Fluel
//
//  Created by Codex on 2026/07/13.
//

import MHUI
import PhotosUI
import SwiftUI

struct EntryPhotoEditorSection: View {
    private enum Layout {
        static let maximumImageHeight = 280.0
        static let cornerRadius = 12.0
    }

    @Binding var photoData: Data?
    @Binding var selectedPhotoItem: PhotosPickerItem?

    let isProcessingPhoto: Bool
    let cancelPhotoProcessing: () -> Void

    var body: some View {
        Section {
            EntryPhotoEditorContent(
                photoData: $photoData,
                selectedPhotoItem: $selectedPhotoItem,
                isProcessingPhoto: isProcessingPhoto,
                maximumImageHeight: Layout.maximumImageHeight,
                cornerRadius: Layout.cornerRadius,
                cancelPhotoProcessing: cancelPhotoProcessing
            )
        } header: {
            FluelSectionHeader("Photo")
        } footer: {
            Text("Choose one photo that helps you remember this entry.")
                .mhSectionFooterText()
        }
    }
}
