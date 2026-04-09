import MHUI
import SwiftUI

struct FluelNoticeBanner: View {
    @Environment(\.mhDesignMetrics)
    private var metrics

    let notice: FluelNotice
    let dismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: metrics.layout.compactRowAccessorySpacing) {
            Image(systemName: iconName)
                .font(.headline)
                .foregroundStyle(iconColor)
                .accessibilityHidden(true)

            Text(notice.message)
                .font(.callout)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(
                action: dismiss
            ) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .accessibilityLabel(FluelCopy.dismissNotice())
            .buttonStyle(.plain)
        }
        .mhSurfaceInset()
        .mhSurface(role: .muted)
    }

    private var iconName: String {
        switch notice.style {
        case .info:
            return "info.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        }
    }

    private var iconColor: Color {
        switch notice.style {
        case .info:
            return .blue
        case .warning:
            return .orange
        }
    }
}
