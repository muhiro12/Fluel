//
//  EntryPhotoEditorContent.swift
//  Fluel
//
//  Created by Codex on 2026/07/13.
//

import MHUI
import PhotosUI
import SwiftUI

struct EntryPhotoEditorContent: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var photoData: Data?
    @Binding var selectedPhotoItem: PhotosPickerItem?

    let isProcessingPhoto: Bool
    let maximumImageHeight: Double
    let cancelPhotoProcessing: () -> Void

    var body: some View {
        if let photoData {
            EntryPhotoImage(photoData: photoData)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: maximumImageHeight)
                .clipShape(.rect(cornerRadius: designMetrics.cornerRadius.surface))
                .mhRow()
        }

        if isProcessingPhoto {
            HStack {
                ProgressView()
                Text("Preparing Photo")
            }
            .mhRow()

            MHActionGroup {
                Button("Cancel Photo", role: .cancel, action: cancelPhotoProcessing)
                    .buttonStyle(.mhQuiet)
            }
        } else if photoData == nil {
            MHActionGroup {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("Add Photo", systemImage: "photo.badge.plus")
                }
            }
        } else {
            MHActionGroup {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("Replace Photo", systemImage: "photo.badge.plus")
                }

                Button(role: .destructive) {
                    photoData = nil
                    selectedPhotoItem = nil
                } label: {
                    Label("Remove Photo", systemImage: "trash")
                }
                .buttonStyle(.mhDestructive)
            }
        }
    }
}
