import FluelLibrary
import MHUI
import SwiftData
import SwiftUI
import UIKit

struct EntryRowView: View {
    private enum Metrics {
        static let imageSize: CGFloat = 48
        static let elapsedWidth: CGFloat = 120
        static let badgeSpacing: CGFloat = 6
    }

    @Environment(\.mhTheme)
    private var theme
    @Environment(\.locale)
    private var locale

    let entry: Entry
    let referenceDate: Date
    let footerText: String?
    let showsMetadataBadges: Bool

    var body: some View {
        let snapshot = EntryElapsedSnapshot(
            startComponents: entry.startComponents,
            referenceDate: referenceDate
        )

        return content(
            snapshot: snapshot
        )
    }

    init(
        entry: Entry,
        referenceDate: Date,
        footerText: String? = nil,
        showsMetadataBadges: Bool = true
    ) {
        self.entry = entry
        self.referenceDate = referenceDate
        self.footerText = footerText
        self.showsMetadataBadges = showsMetadataBadges
    }

    private func content(
        snapshot: EntryElapsedSnapshot
    ) -> some View {
        let metadataBadges = EntryFormatting.metadataBadgeTexts(
            for: entry,
            locale: locale
        )

        return HStack(alignment: .top, spacing: theme.spacing.control) {
            if let image = entryImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: Metrics.imageSize,
                        height: Metrics.imageSize
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: theme.radius.control,
                            style: .continuous
                        )
                    )
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: theme.spacing.inline) {
                Text(
                    EntryFormatting.startLabelText(
                        for: entry.startComponents
                    )
                )
                .mhRowOverline()

                Text(entry.title)
                    .mhRowTitle()

                if showsMetadataBadges,
                   metadataBadges.isEmpty == false {
                    HStack(spacing: Metrics.badgeSpacing) {
                        ForEach(metadataBadges, id: \.self) { badge in
                            Text(badge)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .foregroundStyle(.secondary)
                                .background {
                                    Capsule(style: .continuous)
                                        .fill(
                                            Color.secondary.opacity(0.14)
                                        )
                                }
                        }
                    }
                }

                if let footerText {
                    Text(footerText)
                        .mhRowSupporting()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: theme.layout.rowAccessorySpacing)

            Text(
                EntryFormatting.primaryElapsedText(
                    for: snapshot
                )
            )
            .mhTextStyle(.bodyStrong, colorRole: .primaryText)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: Metrics.elapsedWidth, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: entry.isArchived ? .muted : .standard)
    }

    private var entryImage: UIImage? {
        guard let photoData = entry.photoData else {
            return nil
        }

        return UIImage(data: photoData)
    }
}

#Preview {
    EntryRowPreview()
}

private struct EntryRowPreview: View {
    var body: some View {
        if let preview = previewContent {
            preview
        } else {
            Text("Preview unavailable")
                .fluelAppStyle()
        }
    }

    private var previewContent: AnyView? {
        guard let context = try? FluelSampleData.makeSharedContext(),
              let entry = try? previewEntry(
                  context: context.modelContainer.mainContext
              ) else {
            return nil
        }

        return AnyView(
            EntryRowView(
                entry: entry,
                referenceDate: .now
            )
            .modelContainer(context.modelContainer)
            .fluelAppStyle()
        )
    }

    private func previewEntry(
        context: ModelContext
    ) throws -> Entry {
        let entries = try context.fetch(FetchDescriptor<Entry>())

        if let activeEntry = EntryListOrdering.active(entries).first {
            return activeEntry
        }

        guard let firstEntry = entries.first else {
            throw PreviewError.missingEntry
        }

        return firstEntry
    }
}

private enum PreviewError: Error {
    case missingEntry
}
