import FluelLibrary
import SwiftUI

struct EntryContentFilterBar: View {
    @Namespace private var chipNamespace

    @Binding var selection: EntryContentFilterMode

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            GlassEffectContainer(
                spacing: FluelPresentationStyle.chipSpacing
            ) {
                HStack(spacing: FluelPresentationStyle.chipSpacing) {
                    ForEach(EntryContentFilterMode.allCases, id: \.self) { mode in
                        Button {
                            selection = mode
                        } label: {
                            FluelGlassPill(
                                title: FluelCopy.entryContentFilterMode(mode),
                                kind: selection == mode
                                    ? .accent
                                    : .neutral,
                                emphasizesSelection: selection == mode
                            )
                            .glassEffectID(
                                mode,
                                in: chipNamespace
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}
