import SwiftUI

struct EntryPresetStrip: View {
    @Namespace private var presetNamespace

    var title: String = FluelCopy.quickPresets()
    var subtitle: String = FluelCopy.quickPresetsBody()
    let presets: [EntryPreset]
    let selectedPresetID: String?
    let onSelect: (EntryPreset) -> Void

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.inlineSpacing
        ) {
            Text(title)
                .fluelSectionTitleStyle()

            Text(subtitle)
                .fluelSupportingStyle()

            ScrollView(.horizontal, showsIndicators: false) {
                GlassEffectContainer(
                    spacing: FluelPresentationStyle.inlineSpacing
                ) {
                    HStack(spacing: FluelPresentationStyle.inlineSpacing) {
                        ForEach(presets) { preset in
                            Button {
                                onSelect(preset)
                            } label: {
                                presetCard(for: preset)
                                    .glassEffectID(
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

        return VStack(
            alignment: .leading,
            spacing: FluelPresentationStyle.compactSpacing
        ) {
            HStack(
                alignment: .firstTextBaseline,
                spacing: FluelPresentationStyle.inlineSpacing
            ) {
                Label(
                    preset.title,
                    systemImage: preset.symbolName
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tint)
                }
            }

            Text(
                EntryPresetFormatting.detailText(for: preset)
            )
            .fluelMetadataStyle(
                color: isSelected ? .accentColor : .secondary
            )

            if let note = preset.note {
                Text(note)
                    .lineLimit(2)
                    .fluelMetadataStyle()
            }
        }
        .frame(width: 220, alignment: .leading)
        .padding(14)
        .glassEffect(
            .regular,
            in: RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .strokeBorder(
                (isSelected ? Color.accentColor : Color.primary)
                    .opacity(isSelected ? 0.35 : 0.08),
                lineWidth: isSelected ? 1.5 : 1
            )
        }
    }
}
