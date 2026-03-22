import FluelLibrary
import SwiftData
import SwiftUI
import UIKit

struct EntryRowView: View {
    private enum Metrics {
        static let imageSize: CGFloat = 48
        static let elapsedWidth: CGFloat = 120
        static let badgeSpacing: CGFloat = 6
    }

    @Environment(\.locale)
    private var locale
    @Namespace private var metadataBadgeNamespace

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

        return HStack(
            alignment: .top,
            spacing: FluelPresentationStyle.rowSpacing
        ) {
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
                            cornerRadius: FluelPresentationStyle.imageCornerRadius,
                            style: .continuous
                        )
                    )
                    .accessibilityHidden(true)
            }

            VStack(
                alignment: .leading,
                spacing: FluelPresentationStyle.inlineSpacing
            ) {
                Text(
                    EntryFormatting.startLabelText(
                        for: entry.startComponents
                    )
                )
                .fluelOverlineStyle()

                Text(entry.title)
                    .fluelRowTitleStyle()

                if showsMetadataBadges,
                   metadataBadges.isEmpty == false {
                    GlassEffectContainer(
                        spacing: Metrics.badgeSpacing
                    ) {
                        HStack(spacing: Metrics.badgeSpacing) {
                            ForEach(
                                Array(metadataBadges.enumerated()),
                                id: \.offset
                            ) { item in
                                FluelGlassPill(title: item.element)
                                    .glassEffectID(
                                        "entry-\(entry.id.uuidString)-metadata-\(item.offset)",
                                        in: metadataBadgeNamespace
                                    )
                            }
                        }
                    }
                }

                if let footerText {
                    Text(footerText)
                        .fluelSupportingStyle()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: FluelPresentationStyle.rowSpacing)

            Text(
                EntryFormatting.primaryElapsedText(
                    for: snapshot
                )
            )
            .fluelRowTitleStyle()
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: Metrics.elapsedWidth, alignment: .trailing)
        }
        .fluelCard(tone: entry.isArchived ? .muted : .standard)
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
            Text(FluelCopy.previewUnavailable())
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
