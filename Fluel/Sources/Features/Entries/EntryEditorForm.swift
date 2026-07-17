//
//  EntryEditorForm.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import MHUI
import PhotosUI
import SwiftUI

struct EntryEditorForm: View {
    @Binding var draft: EntryDraft
    @Binding var photoData: Data?
    @Binding var selectedPhotoItem: PhotosPickerItem?

    let isProcessingPhoto: Bool
    let cancelPhotoProcessing: () -> Void

    var body: some View {
        Form {
            EntryTitleSection(title: $draft.title)

            EntryStartPicker(draft: $draft)

            EntryPhotoEditorSection(
                photoData: $photoData,
                selectedPhotoItem: $selectedPhotoItem,
                isProcessingPhoto: isProcessingPhoto,
                cancelPhotoProcessing: cancelPhotoProcessing
            )

            EntryNoteSection(note: $draft.note)
        }
        .mhFormChrome()
    }
}
