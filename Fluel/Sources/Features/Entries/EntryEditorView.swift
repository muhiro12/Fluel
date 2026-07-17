//
//  EntryEditorView.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import MHUI
import PhotosUI
import SwiftData
import SwiftUI

struct EntryEditorView: View {
    @Environment(\.calendar)
    private var calendar
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var draft: EntryDraft
    @State private var photoData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isConfirmingDiscard = false
    @State private var isProcessingPhoto = false
    @State private var isShowingPhotoError = false
    @State private var isShowingSaveError = false

    private let entry: Entry?
    private let initialDraft: EntryDraft
    private let initialPhotoData: Data?

    var body: some View {
        NavigationStack {
            EntryEditorForm(
                draft: $draft,
                photoData: $photoData,
                selectedPhotoItem: $selectedPhotoItem,
                isProcessingPhoto: isProcessingPhoto,
                cancelPhotoProcessing: cancelPhotoProcessing
            )
            .navigationTitle(editorKind.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                EntryEditorToolbar(
                    canSave: canSave,
                    cancel: cancel,
                    save: save
                )
            }
            .modifier(EntryEditorDiscardConfirmationModifier(
                isPresented: $isConfirmingDiscard,
                kind: editorKind,
                discard: discard
            ))
            .modifier(EntryEditorErrorAlertsModifier(
                isShowingPhotoError: $isShowingPhotoError,
                isShowingSaveError: $isShowingSaveError,
                kind: editorKind
            ))
            .interactiveDismissDisabled(hasChanges)
            .task(id: selectedPhotoItem) {
                await processSelectedPhoto()
            }
        }
        .mhTheme(.standard)
    }

    private var editorKind: EntryEditorKind {
        entry == nil ? .create : .edit
    }

    private var hasChanges: Bool {
        draft.hasContentChanges(
            comparedTo: initialDraft,
            calendar: calendar
        ) || photoData != initialPhotoData
    }

    private var canSave: Bool {
        guard draft.canSave,
              !isProcessingPhoto else {
            return false
        }

        return entry == nil || hasChanges
    }

    init() {
        let emptyDraft = EntryDraft()
        entry = nil
        initialDraft = emptyDraft
        initialPhotoData = nil
        _draft = State(initialValue: emptyDraft)
        _photoData = State(initialValue: nil)
    }

    init(draft: EntryDraft) {
        entry = nil
        initialDraft = draft
        initialPhotoData = nil
        _draft = State(initialValue: draft)
        _photoData = State(initialValue: nil)
    }

    init(draft: EntryDraft, photoData: Data?) {
        entry = nil
        initialDraft = draft
        initialPhotoData = photoData
        _draft = State(initialValue: draft)
        _photoData = State(initialValue: photoData)
    }

    init(editing entry: Entry, draft: EntryDraft, photoData: Data?) {
        self.entry = entry
        initialDraft = draft
        initialPhotoData = photoData
        _draft = State(initialValue: draft)
        _photoData = State(initialValue: photoData)
    }

    private func cancel() {
        if hasChanges {
            isConfirmingDiscard = true
        } else {
            dismiss()
        }
    }

    private func discard() {
        dismiss()
    }

    private func save() {
        do {
            if let entry {
                try EntryStore.update(
                    entry,
                    with: .init(
                        draft: draft,
                        photoData: photoData,
                        updatedAt: .now,
                        calendar: calendar
                    ),
                    in: modelContext
                )
            } else {
                let input = try EntryOperations.makeInput(
                    from: draft,
                    calendar: calendar
                )
                try EntryStore.create(
                    input: input,
                    photoData: photoData,
                    createdAt: .now,
                    in: modelContext
                )
            }

            dismiss()
        } catch {
            isShowingSaveError = true
        }
    }

    private func processSelectedPhoto() async {
        guard let selectedPhotoItem else {
            return
        }

        isProcessingPhoto = true

        do {
            guard let transferredPhoto = try await selectedPhotoItem.loadTransferable(
                type: EntryPhotoTransfer.self
            ) else {
                throw EntryPhotoProcessor.ProcessingError.invalidImage
            }

            try Task.checkCancellation()

            guard self.selectedPhotoItem == selectedPhotoItem else {
                return
            }

            photoData = transferredPhoto.data
            self.selectedPhotoItem = nil
            isProcessingPhoto = false
        } catch is CancellationError {
            if self.selectedPhotoItem == selectedPhotoItem {
                isProcessingPhoto = false
            }
        } catch {
            guard self.selectedPhotoItem == selectedPhotoItem else {
                return
            }

            self.selectedPhotoItem = nil
            isProcessingPhoto = false
            isShowingPhotoError = true
        }
    }

    private func cancelPhotoProcessing() {
        selectedPhotoItem = nil
        isProcessingPhoto = false
    }
}
