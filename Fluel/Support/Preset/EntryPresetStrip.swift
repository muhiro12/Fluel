import MHUI
import SwiftUI

struct EntryPresetStrip: View {
    @Environment(\.mhTheme)
    private var theme

    let presets: [EntryPreset]
    let selectedPresetID: String?
    let onSelect: (EntryPreset) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(FluelCopy.starterPresets())
                .font(.headline)

            Text(FluelCopy.starterPresetsBody())
                .mhTextStyle(.supporting, colorRole: .secondaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing.inline) {
                    ForEach(presets) { preset in
                        Button {
                            onSelect(preset)
                        } label: {
                            presetCard(for: preset)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func presetCard(
        for preset: EntryPreset
    ) -> some View {
        let isSelected = selectedPresetID == preset.id

        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(
                    preset.title,
                    systemImage: preset.symbolName
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.primary)

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
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .mhSurface(role: isSelected ? .standard : .muted)
    }
}
