import FluelLibrary
import MHUI
import SwiftUI

struct EntryActivityScopeFilterBar: View {
    @Environment(\.mhDesignMetrics)
    private var metrics
    @Namespace private var chipNamespace

    @Binding var selection: EntryActivityScopeMode

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            FluelGlassContainer(spacing: metrics.spacing.inline) {
                HStack(spacing: metrics.spacing.inline) {
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
                                .fluelGlassEffectID(mode, in: chipNamespace)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, metrics.layout.compactActionVerticalPadding)
            }
        }
        .mhSurfaceInset()
        .mhSurface(role: .muted)
    }
}
