import SwiftUI
import TipKit

struct PresetSettingsView: View {
    @Environment(EntryPresetStore.self)
    private var presetStore
    @State private var isPresentingCreateSheet = false
    @State private var editingPreset: EntryPreset?
    @State private var deletingPreset: EntryPreset?

    private let defaultPresetTip = FluelTips.DefaultPresetTip()

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: FluelPresentationStyle.sectionSpacing
            ) {
                FluelScreenIntroCard(
                    title: FluelCopy.presets(),
                    subtitle: FluelCopy.presetScreenSubtitle()
                )

                defaultPresetCard

                PresetSettingsSectionCard(
                    title: FluelCopy.pinnedPresets(),
                    presets: presetStore.pinnedPresets,
                    emptyState: .init(
                        title: FluelCopy.noPinnedPresetsTitle(),
                        body: FluelCopy.noPinnedPresetsBody()
                    ),
                    defaultPresetID: presetStore.defaultPresetID,
                    onSelectDefault: selectDefault,
                    onTogglePin: togglePin,
                    onEdit: { preset in
                        editingPreset = preset
                    },
                    onDelete: { preset in
                        deletingPreset = preset
                    }
                )

                PresetSettingsSectionCard(
                    title: FluelCopy.recentPresets(),
                    presets: presetStore.recentPresets,
                    emptyState: .init(
                        title: FluelCopy.noRecentPresetsTitle(),
                        body: FluelCopy.noRecentPresetsBody()
                    ),
                    defaultPresetID: presetStore.defaultPresetID,
                    onSelectDefault: selectDefault,
                    onTogglePin: togglePin,
                    onEdit: { preset in
                        editingPreset = preset
                    },
                    onDelete: { preset in
                        deletingPreset = preset
                    }
                )

                PresetSettingsSectionCard(
                    title: FluelCopy.builtInPresets(),
                    presets: presetStore.builtInPresets,
                    emptyState: nil,
                    defaultPresetID: presetStore.defaultPresetID,
                    onSelectDefault: selectDefault,
                    onTogglePin: togglePin
                )

                PresetSettingsSectionCard(
                    title: FluelCopy.customPresets(),
                    presets: presetStore.customPresets,
                    emptyState: .init(
                        title: FluelCopy.noCustomPresetsTitle(),
                        body: FluelCopy.noCustomPresetsBody()
                    ),
                    defaultPresetID: presetStore.defaultPresetID,
                    onSelectDefault: selectDefault,
                    onTogglePin: togglePin,
                    onEdit: { preset in
                        editingPreset = preset
                    },
                    onDelete: { preset in
                        deletingPreset = preset
                    }
                )
            }
            .padding(FluelPresentationStyle.screenPadding)
        }
        .fluelAppBackground()
        .navigationTitle(FluelCopy.presets())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingCreateSheet = true
                } label: {
                    Label(
                        FluelCopy.newPreset(),
                        systemImage: "plus"
                    )
                }
            }
        }
        .sheet(isPresented: $isPresentingCreateSheet) {
            NavigationStack {
                PresetEditorView(mode: .create) { definition in
                    presetStore.saveCustomPreset(
                        definition: definition
                    )
                }
            }
        }
        .sheet(item: $editingPreset) { preset in
            NavigationStack {
                PresetEditorView(mode: .edit(preset)) { definition in
                    presetStore.saveCustomPreset(
                        id: preset.id,
                        definition: definition
                    )
                }
            }
        }
        .confirmationDialog(
            FluelCopy.deletePresetConfirmationTitle(),
            isPresented: Binding(
                get: {
                    deletingPreset != nil
                },
                set: { isPresented in
                    if isPresented == false {
                        deletingPreset = nil
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            Button(
                FluelCopy.delete(),
                role: .destructive
            ) {
                if let deletingPreset {
                    presetStore.deleteCustomPreset(
                        id: deletingPreset.id
                    )
                }
                deletingPreset = nil
            }

            Button(
                FluelCopy.cancel(),
                role: .cancel
            ) {
                deletingPreset = nil
            }
        } message: {
            Text(
                FluelCopy.deletePresetConfirmationMessage(
                    for: deletingPreset?.title ?? String()
                )
            )
        }
    }

    private var defaultPresetCard: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(FluelCopy.defaultPreset())
                .fluelSectionTitleStyle()

            Toggle(
                FluelCopy.useDefaultPresetForNewEntries(),
                isOn: Binding(
                    get: {
                        presetStore.usesDefaultPreset
                    },
                    set: { newValue in
                        FluelTipState.markDefaultPresetLearned()
                        presetStore.setUsesDefaultPreset(newValue)
                    }
                )
            )
            .disabled(presetStore.defaultPreset == nil)

            if let defaultPreset = presetStore.defaultPreset {
                Label(
                    defaultPreset.title,
                    systemImage: defaultPreset.symbolName
                )
                .fluelRowTitleStyle()

                Text(
                    EntryPresetFormatting.detailText(for: defaultPreset)
                )
                .fluelSupportingStyle()

                if let note = defaultPreset.note {
                    Text(note)
                        .fluelMetadataStyle()
                }

                Button(
                    FluelCopy.clearDefaultPreset()
                ) {
                    FluelTipState.markDefaultPresetLearned()
                    presetStore.setDefaultPreset(id: nil)
                }
                .buttonStyle(.bordered)
            } else {
                Text(FluelCopy.noDefaultPresetTitle())
                    .fluelRowTitleStyle()

                Text(FluelCopy.noDefaultPresetBody())
                    .fluelSupportingStyle()
            }
        }
        .fluelCard(tone: .muted)
        .popoverTip(
            showsDefaultPresetTip ? defaultPresetTip : nil,
            arrowEdge: .top
        )
    }

    private func selectDefault(
        _ preset: EntryPreset
    ) {
        FluelTipState.markDefaultPresetLearned()
        if presetStore.defaultPresetID == preset.id {
            presetStore.setDefaultPreset(id: nil)
            return
        }

        presetStore.setDefaultPreset(id: preset.id)
        presetStore.setUsesDefaultPreset(true)
    }

    private func togglePin(
        _ preset: EntryPreset
    ) {
        presetStore.setPinned(
            preset.isPinned == false,
            for: preset.id
        )
    }

    private var showsDefaultPresetTip: Bool {
        FluelTipBootstrap.isEnabled
            && FluelTipState.hasLearnedDefaultPreset == false
    }
}

private struct PresetSettingsSectionCard: View {
    struct EmptyState {
        let title: String
        let body: String
    }

    let title: String
    let presets: [EntryPreset]
    let emptyState: EmptyState?
    var defaultPresetID: String?
    var onSelectDefault: ((EntryPreset) -> Void)?
    var onTogglePin: ((EntryPreset) -> Void)?
    var onEdit: ((EntryPreset) -> Void)?
    var onDelete: ((EntryPreset) -> Void)?

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(title)
                .fluelSectionTitleStyle()

            if presets.isEmpty, let emptyState {
                VStack(alignment: .leading, spacing: 6) {
                    Text(emptyState.title)
                        .fluelRowTitleStyle()

                    Text(emptyState.body)
                        .fluelSupportingStyle()
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(presets) { preset in
                        PresetSettingsRow(
                            preset: preset,
                            isDefaultPreset: defaultPresetID == preset.id,
                            onSelectDefault: onSelectDefault,
                            onTogglePin: onTogglePin,
                            onEdit: onEdit,
                            onDelete: onDelete
                        )
                        .padding(.vertical, 12)

                        if preset.id != presets.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .fluelCard(tone: .muted)
    }
}

private struct PresetSettingsRow: View {
    @Namespace private var statusBadgeNamespace

    let preset: EntryPreset
    let isDefaultPreset: Bool
    var onSelectDefault: ((EntryPreset) -> Void)?
    var onTogglePin: ((EntryPreset) -> Void)?
    var onEdit: ((EntryPreset) -> Void)?
    var onDelete: ((EntryPreset) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Label(
                    preset.title,
                    systemImage: preset.symbolName
                )
                .fluelRowTitleStyle()

                Text(
                    EntryPresetFormatting.detailText(for: preset)
                )
                .fluelSupportingStyle()

                if let note = preset.note {
                    Text(note)
                        .fluelMetadataStyle()
                }

                if statusBadges.isEmpty == false {
                    GlassEffectContainer(spacing: 8) {
                        HStack(spacing: 8) {
                            ForEach(statusBadges) { badge in
                                FluelGlassPill(
                                    title: badge.title,
                                    kind: badge.kind
                                )
                                .glassEffectID(
                                    "\(preset.id)-status-\(badge.id)",
                                    in: statusBadgeNamespace
                                )
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if hasMenuActions {
                Menu {
                    if let onSelectDefault {
                        Button(
                            isDefaultPreset
                                ? FluelCopy.clearDefaultPreset()
                                : FluelCopy.setAsDefaultPreset()
                        ) {
                            onSelectDefault(preset)
                        }
                    }

                    if let onTogglePin {
                        Button(
                            preset.isPinned
                                ? FluelCopy.unpinPreset()
                                : FluelCopy.pinPreset()
                        ) {
                            onTogglePin(preset)
                        }
                    }

                    if preset.isEditable,
                       let onEdit {
                        Button(
                            FluelCopy.editPreset()
                        ) {
                            onEdit(preset)
                        }
                    }

                    if preset.isEditable,
                       let onDelete {
                        Button(
                            FluelCopy.delete(),
                            role: .destructive
                        ) {
                            onDelete(preset)
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var hasMenuActions: Bool {
        onSelectDefault != nil || onTogglePin != nil || (preset.isEditable && (onEdit != nil || onDelete != nil))
    }

    private var statusBadges: [PresetStatusBadge] {
        [
            isDefaultPreset
                ? .init(
                    id: "default",
                    title: FluelCopy.defaultPresetBadge(),
                    kind: .accent
                )
                : nil,
            preset.isPinned
                ? .init(
                    id: "pinned",
                    title: FluelCopy.pinned(),
                    kind: .positive
                )
                : nil,
            preset.lastUsedAt != nil
                ? .init(
                    id: "recent",
                    title: FluelCopy.recent(),
                    kind: .neutral
                )
                : nil
        ]
        .compactMap(\.self)
    }
}

private struct PresetStatusBadge: Identifiable {
    let id: String
    let title: String
    let kind: FluelBadgeKind
}

#Preview {
    @Previewable var presetStore = EntryPresetStore.preview()

    NavigationStack {
        PresetSettingsView()
    }
    .environment(presetStore)
    .fluelAppStyle()
}
