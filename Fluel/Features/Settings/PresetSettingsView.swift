import MHUI
import SwiftUI

struct PresetSettingsView: View {
    @Environment(\.mhTheme)
    private var theme
    @EnvironmentObject private var presetStore: EntryPresetStore
    @State private var isPresentingCreateSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.section) {
                PresetSettingsSectionCard(
                    title: FluelCopy.builtInPresets(),
                    presets: presetStore.builtInPresets,
                    emptyState: nil
                )

                PresetSettingsSectionCard(
                    title: FluelCopy.customPresets(),
                    presets: presetStore.customPresets,
                    emptyState: .init(
                        title: FluelCopy.noCustomPresetsTitle(),
                        body: FluelCopy.noCustomPresetsBody()
                    )
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
                        PresetSettingsRow(preset: preset)
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

    var body: some View {
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        PresetSettingsView()
    }
    .environmentObject(EntryPresetStore.preview())
    .fluelAppStyle()
}
