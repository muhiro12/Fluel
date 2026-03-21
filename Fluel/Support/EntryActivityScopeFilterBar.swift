import FluelLibrary
import MHUI
import SwiftUI

struct EntryActivityScopeFilterBar: View {
    @Environment(\.mhTheme)
    private var theme
    @Namespace private var chipNamespace

    @Binding var selection: EntryActivityScopeMode

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            MHGlassContainer(spacing: theme.spacing.inline) {
                HStack(spacing: theme.spacing.inline) {
                    ForEach(EntryActivityScopeMode.allCases, id: \.self) { mode in
                        Button {
                            selection = mode
                        } label: {
                            Text(FluelCopy.entryActivityScopeMode(mode))
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
