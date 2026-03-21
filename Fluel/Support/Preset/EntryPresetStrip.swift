import MHUI
import SwiftUI

struct EntryPresetStrip: View {
    @Environment(\.mhTheme)
    private var theme
    @Namespace private var presetNamespace

    var title: String = FluelCopy.quickPresets()
    var subtitle: String = FluelCopy.quickPresetsBody()
    let presets: [EntryPreset]
    let selectedPresetID: String?
    let onSelect: (EntryPreset) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(title)
                .mhTextStyle(.sectionTitle)

            Text(subtitle)
                .mhSectionHeaderSupporting()

            ScrollView(.horizontal, showsIndicators: false) {
                MHGlassContainer(spacing: theme.spacing.inline) {
                    HStack(spacing: theme.spacing.inline) {
                        ForEach(presets) { preset in
                            Button {
                                onSelect(preset)
                            } label: {
                                presetCard(for: preset)
                                    .mhGlassEffectID(
                                        preset.id,
                                        in: presetNamespace
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func presetCard(
        for preset: EntryPreset
    ) -> some View {
        let isSelected = selectedPresetID == preset.id

        return VStack(alignment: .leading, spacing: theme.spacing.inline) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.inline) {
                Label(
                    preset.title,
                    systemImage: preset.symbolName
                )
                .mhRowTitle()

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tint)
                }
            }

            Text(
                EntryPresetFormatting.detailText(for: preset)
            )
            .mhTextStyle(.metadata, colorRole: .secondaryText)

            if let note = preset.note {
                Text(note)
                    .lineLimit(2)
                    .mhTextStyle(.metadata, colorRole: .secondaryText)
            }
        }
        .frame(width: 220, alignment: .leading)
        .mhSurfaceInset()
        .mhSurface(role: isSelected ? .standard : .muted)
    }
}
