import MHUI
import SwiftUI

struct PresetSettingsView: View {
    @Environment(\.mhTheme)
    private var theme
    @EnvironmentObject private var presetStore: EntryPresetStore
    @State private var isPresentingCreateSheet = false
    @State private var editingPreset: EntryPreset?
    @State private var deletingPreset: EntryPreset?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.section) {
                PresetSettingsSectionCard(
                    title: FluelCopy.pinnedPresets(),
                    presets: presetStore.pinnedPresets,
                    emptyState: .init(
                        title: FluelCopy.noPinnedPresetsTitle(),
                        body: FluelCopy.noPinnedPresetsBody()
                    ),
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
                    onTogglePin: togglePin
                )

                PresetSettingsSectionCard(
                    title: FluelCopy.customPresets(),
                    presets: presetStore.customPresets,
                    emptyState: .init(
                        title: FluelCopy.noCustomPresetsTitle(),
                        body: FluelCopy.noCustomPresetsBody()
                    ),
                    onTogglePin: togglePin,
                    onEdit: { preset in
                        editingPreset = preset
                    },
                    onDelete: { preset in
                        deletingPreset = preset
                    }
                )
            }
            .mhSurfaceInset()
        }
        .mhScreen(
            title: Text(FluelCopy.presets()),
            subtitle: Text(FluelCopy.presetScreenSubtitle())
        )
        .navigationBarTitleDisplayMode(.inline)
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

    private func togglePin(
        _ preset: EntryPreset
    ) {
        presetStore.setPinned(
            preset.isPinned == false,
            for: preset.id
        )
    }
}

private struct PresetSettingsSectionCard: View {
    struct EmptyState {
        let title: String
        let body: String
    }

    @Environment(\.mhTheme)
    private var theme

    let title: String
    let presets: [EntryPreset]
    let emptyState: EmptyState?
    var onTogglePin: ((EntryPreset) -> Void)? = nil
    var onEdit: ((EntryPreset) -> Void)? = nil
    var onDelete: ((EntryPreset) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(title)
                .font(.headline)

            if presets.isEmpty, let emptyState {
                VStack(alignment: .leading, spacing: 6) {
                    Text(emptyState.title)
                        .mhRowTitle()

                    Text(emptyState.body)
                        .mhRowSupporting()
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(presets) { preset in
                        PresetSettingsRow(
                            preset: preset,
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: .muted)
    }
}

private struct PresetSettingsRow: View {
    let preset: EntryPreset
    var onTogglePin: ((EntryPreset) -> Void)? = nil
    var onEdit: ((EntryPreset) -> Void)? = nil
    var onDelete: ((EntryPreset) -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Label(
                    preset.title,
                    systemImage: preset.symbolName
                )
                .mhRowTitle()

                Text(
                    EntryPresetFormatting.detailText(for: preset)
                )
                .mhRowSupporting()

                if let note = preset.note {
                    Text(note)
                        .mhTextStyle(.metadata, colorRole: .secondaryText)
                }

                if let statusText {
                    Text(statusText)
                        .mhTextStyle(.metadata, colorRole: .secondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if hasMenuActions {
                Menu {
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
        onTogglePin != nil || (preset.isEditable && (onEdit != nil || onDelete != nil))
    }

    private var statusText: String? {
        let labels = [
            preset.isPinned ? FluelCopy.pinned() : nil,
            preset.lastUsedAt != nil ? FluelCopy.recent() : nil
        ]
        .compactMap { $0 }

        if labels.isEmpty {
            return nil
        }

        return labels.joined(separator: " • ")
    }
}

#Preview {
    NavigationStack {
        PresetSettingsView()
    }
    .environmentObject(EntryPresetStore.preview())
    .fluelAppStyle()
}
