import FluelLibrary
import SwiftUI

struct PresetEditorView: View {
    enum Mode {
        case create
        case edit(EntryPreset)
    }

    private enum SymbolOption: String, CaseIterable, Identifiable {
        case house
        case wallet = "wallet.pass"
        case bag
        case shoes = "shoeprints.fill"
        case watch = "applewatch.watchface"
        case notebook
        case plant = "leaf"
        case sofa
        case mug
        case heart = "heart.text.square"

        var id: String {
            rawValue
        }
    }

    @Environment(\.dismiss)
    private var dismiss

    @State private var title: String
    @State private var symbolName: String
    @State private var startPrecision: EntryDatePrecision
    @State private var relativeValue: Int
    @State private var note: String

    private let mode: Mode
    private let onSave: (EntryPresetDefinition) -> Void

    init(
        mode: Mode,
        onSave: @escaping (EntryPresetDefinition) -> Void
    ) {
        self.mode = mode
        self.onSave = onSave

        switch mode {
        case .create:
            _title = State(initialValue: String())
            _symbolName = State(initialValue: SymbolOption.house.rawValue)
            _startPrecision = State(initialValue: .month)
            _relativeValue = State(initialValue: 6)
            _note = State(initialValue: String())
        case let .edit(preset):
            _title = State(initialValue: preset.title)
            _symbolName = State(initialValue: preset.symbolName)
            _startPrecision = State(initialValue: preset.startPrecision)
            _relativeValue = State(initialValue: preset.relativeValue)
            _note = State(initialValue: preset.note ?? String())
        }
    }

    var body: some View {
        Form {
            Section {
                Text(FluelCopy.presetEditorSubtitle())
                    .fluelSupportingStyle()
                    .fixedSize(horizontal: false, vertical: true)
            }

            Section {
                TextField(
                    FluelCopy.titlePlaceholder(),
                    text: $title
                )
                .textInputAutocapitalization(.words)
            } header: {
                Text(FluelCopy.titleFieldLabel())
            }

            Section {
                Picker(
                    FluelCopy.presetSymbolLabel(),
                    selection: $symbolName
                ) {
                    ForEach(SymbolOption.allCases) { option in
                        Label(
                            option.rawValue,
                            systemImage: option.rawValue
                        )
                        .tag(option.rawValue)
                    }
                }
                .pickerStyle(.menu)
            } header: {
                Text(FluelCopy.presetSymbolLabel())
            }

            Section {
                Picker(
                    FluelCopy.precisionLabel(),
                    selection: $startPrecision
                ) {
                    Text(FluelCopy.day())
                        .tag(EntryDatePrecision.day)
                    Text(FluelCopy.month())
                        .tag(EntryDatePrecision.month)
                    Text(FluelCopy.year())
                        .tag(EntryDatePrecision.year)
                }
                .pickerStyle(.segmented)

                Stepper(
                    value: $relativeValue,
                    in: relativeRange
                ) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(
                            EntryPresetFormatting.startText(for: definition)
                        )
                        .fluelRowTitleStyle()

                        Text(
                            EntryFormatting.precisionText(
                                for: startPrecision
                            )
                        )
                        .fluelMetadataStyle()
                    }
                }
            } header: {
                Text(FluelCopy.presetOffsetLabel())
            }

            Section {
                TextEditor(text: $note)
                    .frame(minHeight: 120)
            } header: {
                Text(FluelCopy.noteSectionTitle())
            } footer: {
                Text(
                    EntryPresetFormatting.detailText(
                        for: previewPreset
                    )
                )
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .fluelAppBackground()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(FluelCopy.cancel()) {
                    dismiss()
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Button(saveButtonTitle) {
                    onSave(definition)
                    dismiss()
                }
                .bold()
                .disabled(definition.trimmedTitle.isEmpty)
            }
        }
    }
}

private extension PresetEditorView {
    var navigationTitle: String {
        switch mode {
        case .create:
            return FluelCopy.newPreset()
        case .edit:
            return FluelCopy.edit()
        }
    }

    var saveButtonTitle: String {
        switch mode {
        case .create:
            return FluelCopy.createPreset()
        case .edit:
            return FluelCopy.save()
        }
    }

    var definition: EntryPresetDefinition {
        .init(
            title: title,
            symbolName: symbolName,
            startPrecision: startPrecision,
            relativeValue: relativeValue,
            note: note
        )
    }

    var previewPreset: EntryPreset {
        .init(
            id: "preview",
            source: .custom,
            definition: definition,
            isPinned: false,
            lastUsedAt: nil,
            createdAt: nil,
            updatedAt: nil
        )
    }

    var relativeRange: ClosedRange<Int> {
        switch startPrecision {
        case .day:
            return 0 ... 1_825
        case .month:
            return 0 ... 240
        case .year:
            return 0 ... 50
        }
    }
}

#Preview {
    NavigationStack {
        PresetEditorView(mode: .create) { _ in }
    }
    .fluelAppStyle()
}
