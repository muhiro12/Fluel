// swiftlint:disable no_magic_numbers
import FluelLibrary
import MHUI
import SwiftUI

struct EntryContentFilterBar: View {
    @Environment(\.mhTheme)
    private var theme
    @Namespace private var chipNamespace

    @Binding var selection: EntryContentFilterMode

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            MHGlassContainer(spacing: theme.spacing.inline) {
                HStack(spacing: theme.spacing.inline) {
                    ForEach(EntryContentFilterMode.allCases, id: \.self) { mode in
                        Button {
                            selection = mode
                        } label: {
                            Text(FluelCopy.entryContentFilterMode(mode))
                                .mhBadge(
                                    style: selection == mode
                                        ? .accent
                                        : .neutral
                                )
                                .mhGlassEffectID(mode, in: chipNamespace)
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
