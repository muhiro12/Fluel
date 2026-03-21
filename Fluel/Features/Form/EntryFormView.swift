import FluelLibrary
import MHUI
import PhotosUI
import SwiftData
import SwiftUI
import TipKit

struct EntryFormView: View {
    enum Mode {
        case create
        case edit(Entry)
    }

    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var context
    @Environment(EntryPresetStore.self)
    private var presetStore

    @State private var draft: EntryFormDraft
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPresetID: String?
    @State private var errorMessage: String?
    @State private var isConfirmingDiscard = false

    private let mode: Mode
    private let initialPresetID: String?
    private let createPrecisionTip = FluelTips.CreatePrecisionTip()

    init(
        mode: Mode,
        prefilledInput: EntryFormInput? = nil,
        initialPresetID: String? = nil,
        currentDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.mode = mode
        self.initialPresetID = initialPresetID
        _draft = State(
            initialValue: .init(
                mode: mode,
                prefilledInput: prefilledInput,
                currentDate: currentDate,
                calendar: calendar
            )
        )
        _selectedPresetID = State(initialValue: initialPresetID)
    }

    var body: some View {
        Form {
            if case .create = mode, quickPresets.isEmpty == false {
                EntryFormPresetSection(
                    presets: quickPresets,
                    selectedPresetID: selectedPresetID,
                    onSelect: applyPreset
                )
            }

            EntryFormTitleSection(title: $draft.title)
            EntryFormStartSection(draft: $draft)
                .popoverTip(
                    showsCreatePrecisionTip ? createPrecisionTip : nil,
                    arrowEdge: .top
                )
            EntryFormPhotoSection(
                draft: $draft,
                selectedPhotoItem: $selectedPhotoItem
            )
            EntryFormNoteSection(
                note: $draft.note,
                footerText: draft.noteFooterText
            ) {
                draft.clearNote()
            }
        }
        .mhFormChrome(
            title: Text(navigationTitle),
            subtitle: Text(screenSubtitle)
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .interactiveDismissDisabled(draft.hasUnsavedChanges)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(FluelCopy.cancel()) {
                    attemptDismiss()
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Button(FluelCopy.save()) {
                    save()
                }
                .bold()
                .disabled(draft.canSave == false)
            }
        }
        .task(id: selectedPhotoItem) {
            await loadSelectedPhotoIfNeeded()
        }
        .onChange(of: draft.precision, initial: false) {
            draft.syncForPrecision()

            if case .create = mode {
                FluelTipState.markCreatePrecisionLearned()
            }
        }
        .alert(
            FluelCopy.error(),
            isPresented: Binding(
                get: {
                    errorMessage != nil
                },
                set: { isPresented in
                    if isPresented == false {
                        errorMessage = nil
                    }
                }
            )
        ) {
            Button(FluelCopy.ok(), role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? String())
        }
        .confirmationDialog(
            FluelCopy.discardChangesConfirmationTitle(),
            isPresented: $isConfirmingDiscard,
            titleVisibility: .visible
        ) {
            Button(
                FluelCopy.discardChanges(),
                role: .destructive
            ) {
                dismiss()
            }

            Button(
                FluelCopy.cancel(),
                role: .cancel
            ) {
                isConfirmingDiscard = false
            }
        } message: {
            Text(
                FluelCopy.discardChangesConfirmationMessage()
            )
        }
    }

    private var navigationTitle: String {
        switch mode {
        case .create:
            return FluelCopy.add()
        case .edit:
            return FluelCopy.edit()
        }
    }

    private var screenSubtitle: String {
        switch mode {
        case .create:
            return FluelCopy.createScreenSubtitle()
        case .edit:
            return FluelCopy.editScreenSubtitle()
        }
    }

    private func save() {
        Task {
            switch mode {
            case .create:
                await mutationWorkflow.create(input: draft.input)
            case let .edit(entry):
                await mutationWorkflow.update(
                    entry: entry,
                    input: draft.input
                )
            }
        }
    }

    private func attemptDismiss() {
        if draft.hasUnsavedChanges {
            isConfirmingDiscard = true
            return
        }

        dismiss()
    }

    private func loadSelectedPhotoIfNeeded() async {
        do {
            var updatedDraft = draft
            try await updatedDraft.loadPhoto(from: selectedPhotoItem)
            draft = updatedDraft
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private extension EntryFormView {
    var quickPresets: [EntryPreset] {
        presetStore.suggestedPresets(limit: 6)
    }

    var showsCreatePrecisionTip: Bool {
        guard FluelTipBootstrap.isEnabled else {
            return false
        }

        guard case .create = mode else {
            return false
        }

        return FluelTipState.hasLearnedCreatePrecision == false
    }

    var mutationWorkflow: FluelEntryMutationWorkflow {
        .init(
            context: context,
            calendar: draft.calendar,
            onSuccess: {
                dismiss()
            },
            onError: { message in
                errorMessage = message
            }
        )
    }

    func applyPreset(
        _ preset: EntryPreset
    ) {
        guard case .create = mode else {
            return
        }

        FluelTipState.markPresetSelectionLearned()
        draft = .init(
            mode: .create,
            prefilledInput: presetStore.resolvedInput(
                for: preset,
                referenceDate: draft.currentDate,
                calendar: draft.calendar
            ),
            currentDate: draft.currentDate,
            calendar: draft.calendar
        )
        selectedPresetID = preset.id
        selectedPhotoItem = nil
        presetStore.markUsed(preset.id)
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    @Previewable var presetStore = EntryPresetStore.preview()

    NavigationStack {
        EntryFormView(
            mode: .create
        )
    }
    .environment(presetStore)
    .fluelAppStyle()
}

#Preview("Edit", traits: .modifier(FluelSampleData())) {
    @Previewable var presetStore = EntryPresetStore.preview()

    if let context = try? FluelSampleData.makeSharedContext(),
       let entries = try? context.modelContainer.mainContext.fetch(FetchDescriptor<Entry>()),
       let entry = EntryListOrdering.active(entries).first ?? entries.first {
        NavigationStack {
            EntryFormView(
                mode: .edit(entry)
            )
        }
        .modelContainer(context.modelContainer)
        .environment(presetStore)
        .fluelAppStyle()
    } else {
        Text(FluelCopy.failedToLoadPreview())
    }
}
