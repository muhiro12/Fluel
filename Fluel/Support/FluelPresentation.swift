import SwiftUI
import UIKit

enum FluelCardTone {
    case standard
    case muted
}

enum FluelBadgeKind {
    case neutral
    case accent
    case positive
    case warning

    var foregroundColor: Color {
        switch self {
        case .neutral:
            return .primary
        case .accent:
            return .accentColor
        case .positive:
            return .green
        case .warning:
            return .orange
        }
    }
}

enum FluelPresentationStyle {
    static let screenPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 20
    static let inlineSpacing: CGFloat = 8
    static let compactSpacing: CGFloat = 6
    static let rowSpacing: CGFloat = 12
    static let cardPadding: CGFloat = 18
    static let cardCornerRadius: CGFloat = 24
    static let imageCornerRadius: CGFloat = 24
    static let chipSpacing: CGFloat = 10
    static let borderColor = Color.primary.opacity(0.08)
    static let groupedBackground = Color(uiColor: .systemGroupedBackground)
}

private struct FluelCardModifier: ViewModifier {
    @Environment(\.colorScheme)
    private var colorScheme

    let tone: FluelCardTone

    func body(
        content: Content
    ) -> some View {
        let shape = RoundedRectangle(
            cornerRadius: FluelPresentationStyle.cardCornerRadius,
            style: .continuous
        )

        content
            .padding(FluelPresentationStyle.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(fillColor, in: shape)
            .overlay(
                shape.stroke(
                    FluelPresentationStyle.borderColor,
                    lineWidth: 1
                )
            )
    }

    private var fillColor: Color {
        switch tone {
        case .standard:
            if colorScheme == .dark {
                return Color(uiColor: .secondarySystemBackground)
            }

            return Color(uiColor: .systemBackground)
        case .muted:
            if colorScheme == .dark {
                return Color(uiColor: .tertiarySystemBackground)
            }

            return Color(uiColor: .secondarySystemGroupedBackground)
        }
    }
}

struct FluelScreenIntroCard: View {
    let title: String?
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: FluelPresentationStyle.inlineSpacing) {
            if let title,
               title.isEmpty == false {
                Text(title)
                    .fluelHeadlineStyle()
            }

            Text(subtitle)
                .fluelSupportingStyle()
        }
        .fluelCard(tone: .muted)
    }
}

struct FluelGlassPill: View {
    let title: String
    var kind: FluelBadgeKind = .neutral
    var emphasizesSelection = false

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(kind.foregroundColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .glassEffect(.regular, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(
                        kind.foregroundColor.opacity(
                            emphasizesSelection ? 0.35 : 0.16
                        ),
                        lineWidth: emphasizesSelection ? 1.5 : 1
                    )
            }
    }
}

extension View {
    func fluelAppBackground() -> some View {
        background(FluelPresentationStyle.groupedBackground.ignoresSafeArea())
    }

    func fluelCard(
        tone: FluelCardTone = .standard
    ) -> some View {
        modifier(
            FluelCardModifier(
                tone: tone
            )
        )
    }

    func fluelPrimarySearchable(
        text: Binding<String>,
        prompt: String
    ) -> some View {
        searchable(
            text: text,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text(prompt)
        )
    }

    func fluelHeadlineStyle() -> some View {
        font(.system(.title2, weight: .bold))
            .foregroundStyle(.primary)
    }

    func fluelDisplayStyle() -> some View {
        font(.system(.title, weight: .semibold))
            .foregroundStyle(.primary)
    }

    func fluelMetricStyle() -> some View {
        font(.system(.title2, weight: .semibold))
            .foregroundStyle(.primary)
    }

    func fluelSectionTitleStyle() -> some View {
        font(.headline.weight(.semibold))
            .foregroundStyle(.primary)
    }

    func fluelRowTitleStyle() -> some View {
        font(.body.weight(.semibold))
            .foregroundStyle(.primary)
    }

    func fluelSupportingStyle() -> some View {
        font(.subheadline)
            .foregroundStyle(.secondary)
    }

    func fluelMetadataStyle(
        color: Color = .secondary
    ) -> some View {
        font(.caption.weight(.medium))
            .foregroundStyle(color)
    }

    func fluelOverlineStyle() -> some View {
        font(.caption.weight(.semibold))
            .tracking(0.3)
            .foregroundStyle(.secondary)
    }
}
