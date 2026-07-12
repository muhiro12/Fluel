//
//  EntryPhotoEditorContent.swift
//  Fluel
//
//  Created by Codex on 2026/07/13.
//

import PhotosUI
import SwiftUI

struct EntryPhotoEditorContent: View {
    @Binding var photoData: Data?
    @Binding var selectedPhotoItem: PhotosPickerItem?

    let isProcessingPhoto: Bool
    let maximumImageHeight: Double
    let cornerRadius: Double
    let cancelPhotoProcessing: () -> Void

    var body: some View {
        if let photoData {
            EntryPhotoImage(photoData: photoData)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: maximumImageHeight)
                .clipShape(.rect(cornerRadius: cornerRadius))
        }

        if isProcessingPhoto {
            HStack {
                ProgressView()
                Text("Preparing Photo")
            }

            Button("Cancel Photo", role: .cancel, action: cancelPhotoProcessing)
        } else if photoData == nil {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Label("Add Photo", systemImage: "photo.badge.plus")
            }
        } else {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Label("Replace Photo", systemImage: "photo.badge.plus")
            }

            Button(role: .destructive) {
                photoData = nil
                selectedPhotoItem = nil
            } label: {
                Label("Remove Photo", systemImage: "trash")
            }
        }
    }
}
