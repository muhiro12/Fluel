import FluelLibrary
import MHUI
import SwiftData
import SwiftUI

struct HomeView: View {
    private enum Metrics {
        static let rowSpacing: CGFloat = 12
    }

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
        ContentUnavailableView {
            Label(
                FluelCopy.homeEmptyTitle(),
                systemImage: "square.stack.3d.up"
            )
        } description: {
            Text(FluelCopy.homeEmptyBody())
        } actions: {
            Button(
                FluelCopy.addFirstEntry(),
                action: onAdd
            )
            .buttonStyle(.mhPrimary)
        }
        .mhEmptyStateLayout()
        .mhSurfaceInset()
        .mhSurface()
        .mhScreen(
            title: Text(FluelAppConfiguration.appName),
            subtitle: Text(FluelCopy.homeScreenSubtitle())
        )
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
                .listRowInsets(
                    .init(
                        top: 0,
                        leading: 0,
                        bottom: Metrics.rowSpacing,
                        trailing: 0
                    )
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .mhListChrome(
            title: Text(FluelAppConfiguration.appName),
            subtitle: Text(FluelCopy.homeScreenSubtitle())
        )
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
    .fluelAppStyle()
}
