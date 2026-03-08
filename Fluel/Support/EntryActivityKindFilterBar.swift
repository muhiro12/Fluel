import FluelLibrary
import MHUI
import SwiftUI

struct EntryActivityKindFilterBar: View {
    @Binding var selection: EntryActivityFilterMode

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(EntryActivityFilterMode.allCases, id: \.self) { mode in
                    Button {
                        selection = mode
                    } label: {
                        Text(FluelCopy.entryActivityFilterMode(mode))
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .frame(minHeight: 36)
                            .foregroundStyle(
                                selection == mode
                                    ? AnyShapeStyle(Color.white)
                                    : AnyShapeStyle(.primary)
                            )
                            .background {
                                Capsule(style: .continuous)
                                    .fill(
                                        selection == mode
                                            ? Color.accentColor
                                            : Color.secondary.opacity(0.14)
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .mhSurfaceInset()
        .mhSurface(role: .muted)
    }
}
