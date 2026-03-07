import FluelLibrary
import SwiftData
import SwiftUI
import UIKit

struct EntryRowView: View {
    let entry: Entry
    let referenceDate: Date
    let footerText: String?

    init(
        entry: Entry,
        referenceDate: Date,
        footerText: String? = nil
    ) {
        self.entry = entry
        self.referenceDate = referenceDate
        self.footerText = footerText
    }

    var body: some View {
        let snapshot = EntryElapsedSnapshot(
            startComponents: entry.startComponents,
            referenceDate: referenceDate
        )

        HStack(alignment: .top, spacing: 14) {
            if let image = entryImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.title)
                    .font(.headline.weight(.medium))
                    .foregroundStyle(.primary)

                Text(
                    EntryFormatting.startLabelText(
                        for: entry.startComponents
                    )
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                if let footerText {
                    Text(footerText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 12)

            Text(
                EntryFormatting.primaryElapsedText(
                    for: snapshot
                )
            )
            .font(.headline.weight(.semibold))
            .multilineTextAlignment(.trailing)
            .foregroundStyle(.primary)
            .frame(maxWidth: 120, alignment: .trailing)
        }
        .padding(.vertical, 8)
    }

    private var entryImage: UIImage? {
        guard let photoData = entry.photoData else {
            return nil
        }

        return UIImage(data: photoData)
    }
}

#Preview {
    let context = try! FluelSampleData.makeSharedContext()
    let entries = try! context.modelContainer.mainContext.fetch(FetchDescriptor<Entry>())

    return EntryRowView(
        entry: EntryListOrdering.active(entries).first ?? entries[0],
        referenceDate: .now
    )
    .modelContainer(context.modelContainer)
}
