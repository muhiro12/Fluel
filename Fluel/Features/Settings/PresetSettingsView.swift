// swiftlint:disable accessibility_label_for_image closure_body_length
// swiftlint:disable file_length file_types_order no_magic_numbers
// swiftlint:disable one_declaration_per_file type_contents_order
import MHUI
import SwiftUI
import TipKit

struct PresetSettingsView: View {
    @Environment(\.mhTheme)
    private var theme
    @Environment(EntryPresetStore.self)
    private var presetStore
    @Environment(FluelNoticeCenter.self)
    private var noticeCenter
    @State private var model = PresetSettingsScreenModel()

    private let defaultPresetTip = FluelTips.DefaultPresetTip()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.fluelSectionSpacing) {
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
                    onEdit: model.presentEdit(_:),
                    onDelete: model.presentDelete(_:)
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
                    onEdit: model.presentEdit(_:),
                    onDelete: model.presentDelete(_:)
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
                    onEdit: model.presentEdit(_:),
                    onDelete: model.presentDelete(_:)
                )
            }
            .mhSurfaceInset()
        }
        .mhScreen(
            title: Text(FluelCopy.presets()),
            subtitle: Text(FluelCopy.presetScreenSubtitle())
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    model.presentCreate()
                } label: {
                    Label(
                        FluelCopy.newPreset(),
                        systemImage: "plus"
                    )
                }
            }
        }
        .sheet(item: sheetRouteBinding) { route in
            NavigationStack {
                switch route {
                case .create:
                    PresetEditorView(mode: .create) { definition in
                        presetStore.saveCustomPreset(
                            definition: definition
                        )
                    }
                case let .edit(preset):
                    PresetEditorView(mode: .edit(preset)) { definition in
                        presetStore.saveCustomPreset(
                            id: preset.id,
                            definition: definition
                        )
                    }
                }
            }
        }
        .confirmationDialog(
            FluelCopy.deletePresetConfirmationTitle(),
            isPresented: Binding(
                get: {
                    model.deletingPreset != nil
                },
                set: { isPresented in
                    if isPresented == false {
                        model.dismissDeleteConfirmation()
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            Button(
                FluelCopy.delete(),
                role: .destructive
            ) {
                if let deletingPreset = model.deletingPreset {
                    presetStore.deleteCustomPreset(
                        id: deletingPreset.id
                    )
                }
                model.dismissDeleteConfirmation()
            }

            Button(
                FluelCopy.cancel(),
                role: .cancel
            ) {
                model.dismissDeleteConfirmation()
            }
        } message: {
            Text(
                FluelCopy.deletePresetConfirmationMessage(
                    for: model.deletingPreset?.title ?? String()
                )
            )
        }
    }

    private var sheetRouteBinding: Binding<PresetSettingsScreenModel.SheetRoute?> {
        .init(
            get: {
                model.sheetRoute
            },
            set: { newValue in
                model.sheetRoute = newValue
            }
        )
    }

    private var defaultPresetCard: some View {
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            Text(FluelCopy.defaultPreset())
                .mhTextStyle(.sectionTitle)

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
                Text(
                    presetStore.usesDefaultPreset
                        ? FluelCopy.activeDefaultPresetSummary()
                        : FluelCopy.inactiveDefaultPresetSummary()
                )
                .mhRowSupporting()

                Label(
                    defaultPreset.title,
                    systemImage: defaultPreset.symbolName
                )
                .mhRowTitle()

                Text(
                    EntryPresetFormatting.detailText(for: defaultPreset)
                )
                .mhRowSupporting()

                if let note = defaultPreset.note {
                    Text(note)
                        .mhTextStyle(.metadata, colorRole: .secondaryText)
                }

                Button(
                    FluelCopy.clearDefaultPreset()
                ) {
                    clearDefaultPreset()
                }
                .buttonStyle(.mhSecondary)
            } else {
                Text(FluelCopy.noDefaultPresetTitle())
                    .mhRowTitle()

                Text(FluelCopy.noDefaultPresetBody())
                    .mhRowSupporting()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: .muted)
        .popoverTip(
            model.showsDefaultPresetTip() ? defaultPresetTip : nil,
            arrowEdge: .top
        )
    }

    private func selectDefault(
        _ preset: EntryPreset
    ) {
        FluelTipState.markDefaultPresetLearned()
        if presetStore.defaultPresetID == preset.id {
            clearDefaultPreset()
            return
        }

        presetStore.setDefaultPreset(id: preset.id)
        presetStore.setUsesDefaultPreset(true)
        noticeCenter.presentInfo(
            message: FluelCopy.defaultPresetSelectedNotice()
        )
    }

    private func togglePin(
        _ preset: EntryPreset
    ) {
        presetStore.setPinned(
            preset.isPinned == false,
            for: preset.id
        )
    }

    private func clearDefaultPreset() {
        FluelTipState.markDefaultPresetLearned()
        presetStore.setDefaultPreset(id: nil)
        noticeCenter.presentInfo(
            message: FluelCopy.defaultPresetClearedNotice()
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
    var defaultPresetID: String?
    var onSelectDefault: ((EntryPreset) -> Void)?
    var onTogglePin: ((EntryPreset) -> Void)?
    var onEdit: ((EntryPreset) -> Void)?
    var onDelete: ((EntryPreset) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            Text(title)
                .mhTextStyle(.sectionTitle)

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
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: .muted)
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
                .mhRowTitle()

                Text(
                    EntryPresetFormatting.detailText(for: preset)
                )
                .mhRowSupporting()

                if let note = preset.note {
                    Text(note)
                        .mhTextStyle(.metadata, colorRole: .secondaryText)
                }

                if statusBadges.isEmpty == false {
                    FluelGlassContainer(spacing: 8) {
                        HStack(spacing: 8) {
                            ForEach(statusBadges) { badge in
                                Text(badge.title)
                                    .mhBadge(style: badge.style)
                                    .fluelGlassEffectID(
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
                    style: .accent
                )
                : nil,
            preset.isPinned
                ? .init(
                    id: "pinned",
                    title: FluelCopy.pinned(),
                    style: .positive
                )
                : nil,
            preset.lastUsedAt != nil
                ? .init(
                    id: "recent",
                    title: FluelCopy.recent(),
                    style: .neutral
                )
                : nil
        ]
        .compactMap(\.self)
    }
}

private struct PresetStatusBadge: Identifiable {
    let id: String
    let title: String
    let style: MHBadgeStyle
}

#Preview {
    @Previewable var presetStore = EntryPresetStore.preview()

    NavigationStack {
        PresetSettingsView()
    }
    .fluelPreviewEnvironment(presetStore: presetStore)
    .fluelAppStyle()
}
