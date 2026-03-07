import FluelLibrary
import SwiftData
import SwiftUI

struct ArchiveListView: View {
    @Query(
        filter: #Predicate<Entry> { entry in
            entry.archivedAt != nil
        }
    )
    private var archivedEntries: [Entry]

    private var sortedEntries: [Entry] {
        EntryListOrdering.archived(archivedEntries)
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 3_600)) { context in // swiftlint:disable:this no_magic_numbers
            Group {
                if sortedEntries.isEmpty {
                    emptyState
                } else {
                    listContent(referenceDate: context.date)
                }
            }
            .navigationTitle(FluelCopy.archived())
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(FluelCopy.archiveEmptyTitle())
                .font(.title3.weight(.medium))

            Text(FluelCopy.archiveEmptyBody())
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func listContent(
        referenceDate: Date
    ) -> some View {
        List {
            ForEach(sortedEntries) { entry in
                NavigationLink {
                    EntryDetailView(entry: entry)
                } label: {
                    EntryRowView(
                        entry: entry,
                        referenceDate: referenceDate,
                        footerText: entry.archivedAt.map { archivedAt in
                            EntryFormatting.archivedOnText(archivedAt)
                        }
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    NavigationStack {
        ArchiveListView()
    }
}
