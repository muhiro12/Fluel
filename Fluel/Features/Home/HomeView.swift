import FluelLibrary
import MHUI
import SwiftData
import SwiftUI

struct HomeView: View {
    private enum Metrics {
        static let rowSpacing: CGFloat = 12
    }

    @Environment(\.modelContext)
    private var context

    @Query(
        filter: #Predicate<Entry> { entry in
            entry.archivedAt == nil
        }
    )
    private var activeEntries: [Entry]

    @State private var errorMessage: String?

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
        .alert(
            FluelCopy.error(),
            isPresented: Binding(
                get: {
                    errorMessage != nil
                },
                set: { isPresented in
                    if isPresented == false {
                        errorMessage = nil
                    }
                }
            )
        ) {
            Button(FluelCopy.ok(), role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? String())
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
                .swipeActions(
                    edge: .trailing,
                    allowsFullSwipe: false
                ) {
                    Button {
                        archive(entry)
                    } label: {
                        Label(
                            FluelCopy.archive(),
                            systemImage: "archivebox"
                        )
                    }
                    .tint(.orange)
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

    private func archive(
        _ entry: Entry
    ) {
        do {
            try EntryRepository.archive(
                context: context,
                entry: entry
            )
            FluelWidgetReloader.reloadAllTimelines()
        } catch {
            errorMessage = error.localizedDescription
        }
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
