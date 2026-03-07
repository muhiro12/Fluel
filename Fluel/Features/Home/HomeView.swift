import FluelLibrary
import SwiftData
import SwiftUI

struct HomeView: View {
    @Query(
        filter: #Predicate<Entry> { entry in
            entry.archivedAt == nil
        }
    )
    private var activeEntries: [Entry]

    let onAdd: () -> Void
    let onShowArchive: () -> Void
    let onShowLicenses: () -> Void

    private var sortedEntries: [Entry] {
        EntryListOrdering.active(activeEntries)
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
            .navigationTitle(FluelAppConfiguration.appName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button(
                            FluelCopy.archived()
                        ) {
                            onShowArchive()
                        }

                        Button(
                            FluelCopy.licenses()
                        ) {
                            onShowLicenses()
                        }
                    } label: {
                        Label(
                            FluelCopy.more(),
                            systemImage: "ellipsis.circle"
                        )
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onAdd()
                    } label: {
                        Label(
                            FluelCopy.add(),
                            systemImage: "plus"
                        )
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(FluelCopy.homeEmptyTitle())
                .font(.title2.weight(.medium))

            Text(FluelCopy.homeEmptyBody())
                .foregroundStyle(.secondary)

            Button(
                FluelCopy.addFirstEntry(),
                action: onAdd
            )
            .buttonStyle(.borderedProminent)

            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(uiColor: .systemGroupedBackground))
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
                        referenceDate: referenceDate
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    NavigationStack {
        HomeView(
            onAdd: {},
            onShowArchive: {},
            onShowLicenses: {}
        )
    }
}
