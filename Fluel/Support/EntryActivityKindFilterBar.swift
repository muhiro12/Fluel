// swiftlint:disable no_magic_numbers
import FluelLibrary
import MHUI
import SwiftUI

struct EntryActivityKindFilterBar: View {
    @Environment(\.mhTheme)
    private var theme
    @Namespace private var chipNamespace

    @Binding var selection: EntryActivityFilterMode

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            FluelGlassContainer(spacing: theme.fluelInlineSpacing) {
                HStack(spacing: theme.fluelInlineSpacing) {
                    ForEach(EntryActivityFilterMode.allCases, id: \.self) { mode in
                        Button {
                            selection = mode
                        } label: {
                            Text(FluelCopy.entryActivityFilterMode(mode))
                                .mhBadge(
                                    style: selection == mode
                                        ? .accent
                                        : .neutral
                                )
                                .fluelGlassEffectID(mode, in: chipNamespace)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .mhSurfaceInset()
        .mhSurface(role: .muted)
    }
}
