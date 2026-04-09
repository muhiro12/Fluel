import FluelLibrary
import MHUI
import SwiftUI

struct EntryActivityKindFilterBar: View {
    @Environment(\.mhDesignMetrics)
    private var metrics
    @Namespace private var chipNamespace

    @Binding var selection: EntryActivityFilterMode

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            FluelGlassContainer(spacing: metrics.spacing.inline) {
                HStack(spacing: metrics.spacing.inline) {
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
            }
        }
        .mhSurfaceInset()
        .mhSurface(role: .muted)
    }
}
