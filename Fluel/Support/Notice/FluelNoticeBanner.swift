import SwiftUI

struct FluelNoticeBanner: View {
    private enum Layout {
        static let spacing: CGFloat = 12
        static let padding: CGFloat = 14
        static let cornerRadius: CGFloat = 18
        static let borderOpacity = 0.45
        static let shadowOpacity = 0.18
        static let shadowRadius: CGFloat = 12
        static let shadowYOffset: CGFloat = 6
        static let infoBackgroundOpacity = 0.12
        static let warningBackgroundOpacity = 0.14
    }

    let notice: FluelNotice
    let dismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: Layout.spacing) {
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
        .padding(Layout.padding)
        .background(
            backgroundColor,
            in: RoundedRectangle(cornerRadius: Layout.cornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: Layout.cornerRadius)
                .strokeBorder(borderColor.opacity(Layout.borderOpacity))
        }
        .shadow(
            color: borderColor.opacity(Layout.shadowOpacity),
            radius: Layout.shadowRadius,
            y: Layout.shadowYOffset
        )
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

    private var backgroundColor: Color {
        switch notice.style {
        case .info:
            return Color.blue.opacity(Layout.infoBackgroundOpacity)
        case .warning:
            return Color.orange.opacity(Layout.warningBackgroundOpacity)
        }
    }

    private var borderColor: Color {
        switch notice.style {
        case .info:
            return .blue
        case .warning:
            return .orange
        }
    }
}
