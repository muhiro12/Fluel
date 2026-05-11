import FluelLibrary
import MHUI
import SwiftUI

struct EntryContentFilterBar: View {
    @Environment(\.mhDesignMetrics)
    private var metrics
    @Namespace private var chipNamespace

    @Binding var selection: EntryContentFilterMode

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            FluelGlassContainer(spacing: metrics.spacing.inline) {
                HStack(spacing: metrics.spacing.inline) {
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
                                .fluelGlassEffectID(mode, in: chipNamespace)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, metrics.spacing.inline)
            }
        }
        .mhSurfaceInset()
        .mhSurface(role: .muted)
    }
}
