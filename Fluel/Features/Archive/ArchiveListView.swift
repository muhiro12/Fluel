import FluelLibrary
import SwiftData
import SwiftUI
import TipKit

struct ArchiveListView: View {
    private enum Metrics {
        static let rowSpacing: CGFloat = 12
    }

    @Environment(\.modelContext)
    private var context

    @Query(
        filter: #Predicate<Entry> { entry in
            entry.archivedAt != nil
        }
    )
    private var archivedEntries: [Entry]

    @State private var errorMessage: String?
    @State private var pendingDeleteEntry: Entry?
    @State private var searchText = String()
    @AppStorage(
        EntryListPreferences.archiveSortMode,
        store: EntryListPreferences.store
    )
    private var storedSortMode = ArchivedEntrySortMode.recentlyArchived.rawValue
    @AppStorage(
        EntryListPreferences.archiveContentFilter,
        store: EntryListPreferences.store
    )
    private var storedContentFilter = EntryContentFilterMode.all.rawValue
    @AppStorage(
        DisplayPreferences.showsListSummaryCards,
        store: DisplayPreferences.store
    )
    private var showsListSummaryCards = true
    @AppStorage(
        DisplayPreferences.showsNotePreviews,
        store: DisplayPreferences.store
    )
    private var showsNotePreviews = true
    @AppStorage(
        DisplayPreferences.showsMetadataBadges,
        store: DisplayPreferences.store
    )
    private var showsMetadataBadges = true
    @Namespace private var detailTransition

    private let contentFiltersTip = FluelTips.ContentFiltersTip()

    private var sortedEntries: [Entry] {
        EntryListOrdering.archived(
            archivedEntries,
            sortMode: sortMode
        )
    }

    private var displayedEntries: [Entry] {
        EntrySearchMatcher.filter(
            contentFilteredEntries,
            matching: searchText
        )
    }

    private var contentFilteredEntries: [Entry] {
        EntryContentFilter.filter(
            sortedEntries,
            mode: contentFilter
        )
    }

    private var sortMode: ArchivedEntrySortMode {
        ArchivedEntrySortMode(rawValue: storedSortMode) ?? .recentlyArchived
    }

    private var contentFilter: EntryContentFilterMode {
        EntryContentFilterMode(rawValue: storedContentFilter) ?? .all
    }

    private var contentFilterBinding: Binding<EntryContentFilterMode> {
        .init(
            get: {
                contentFilter
            },
            set: { newValue in
                storedContentFilter = newValue.rawValue
                if newValue != .all {
                    FluelTipState.markContentFiltersLearned()
                }
            }
        )
    }

    private var hasActiveSearch: Bool {
        searchText.isEmpty == false
    }

    private var hasActiveFilter: Bool {
        contentFilter != .all
    }

    private var summary: FluelEntryListSummary {
        .init(
            headline: FluelCopy.archivedEntryCount(sortedEntries.count),
            displayedEntries: displayedEntries,
            totalEntries: sortedEntries,
            sortLabel: FluelCopy.archivedSortMode(sortMode),
            filterLabel: FluelCopy.entryContentFilterMode(contentFilter)
        )
    }

    private var mutationWorkflow: FluelEntryMutationWorkflow {
        .init(
            context: context,
            onError: { message in
                errorMessage = message
            }
        )
    }

    private var showsContentFiltersTip: Bool {
        FluelTipBootstrap.isEnabled
            && FluelTipState.hasLearnedContentFilters == false
            && sortedEntries.isEmpty == false
            && displayedEntries.isEmpty == false
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 3_600)) { context in // swiftlint:disable:this no_magic_numbers
            Group {
                if sortedEntries.isEmpty {
                    emptyState
                } else if displayedEntries.isEmpty {
                    searchEmptyState
                } else {
                    listContent(referenceDate: context.date)
                }
            }
        }
        .navigationTitle(FluelCopy.archived())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Section(FluelCopy.sort()) {
                        ForEach(ArchivedEntrySortMode.allCases, id: \.self) { mode in
                            Button {
                                storedSortMode = mode.rawValue
                            } label: {
                                if sortMode == mode {
                                    Label(
                                        FluelCopy.archivedSortMode(mode),
                                        systemImage: "checkmark"
                                    )
                                } else {
                                    Text(
                                        FluelCopy.archivedSortMode(mode)
                                    )
                                }
                            }
                        }
                    }
                } label: {
                    Label(
                        FluelCopy.sort(),
                        systemImage: "arrow.up.arrow.down.circle"
                    )
                }
            }
        }
        .searchable(
            text: $searchText,
            prompt: FluelCopy.searchEntries()
        )
        .confirmationDialog(
            FluelCopy.deleteConfirmationTitle(),
            isPresented: Binding(
                get: {
                    pendingDeleteEntry != nil
                },
                set: { isPresented in
                    if isPresented == false {
                        pendingDeleteEntry = nil
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            Button(
                FluelCopy.deletePermanently(),
                role: .destructive
            ) {
                deletePendingEntry()
            }

            Button(
                FluelCopy.cancel(),
                role: .cancel
            ) {
                pendingDeleteEntry = nil
            }
        } message: {
            Text(
                FluelCopy.deleteConfirmationMessage(
                    for: pendingDeleteEntry?.title ?? String()
                )
            )
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
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: FluelPresentationStyle.sectionSpacing
            ) {
                FluelScreenIntroCard(
                    title: FluelCopy.archived(),
                    subtitle: FluelCopy.archiveScreenSubtitle()
                )

                ContentUnavailableView {
                    Label(
                        FluelCopy.archiveEmptyTitle(),
                        systemImage: "archivebox"
                    )
                } description: {
                    Text(FluelCopy.archiveEmptyBody())
                }
                .fluelCard(tone: .muted)
            }
            .padding(FluelPresentationStyle.screenPadding)
        }
        .fluelAppBackground()
    }

    private var searchEmptyState: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: FluelPresentationStyle.sectionSpacing
            ) {
                FluelScreenIntroCard(
                    title: FluelCopy.archived(),
                    subtitle: FluelCopy.archiveScreenSubtitle()
                )

                ContentUnavailableView {
                    Label(
                        FluelCopy.archiveSearchEmptyTitle(),
                        systemImage: "magnifyingglass"
                    )
                } description: {
                    Text(FluelCopy.archiveSearchEmptyBody())
                }
                .fluelCard(tone: .muted)
            }
            .padding(FluelPresentationStyle.screenPadding)
        }
        .fluelAppBackground()
    }

    private func listContent(
        referenceDate: Date
    ) -> some View {
        List {
            FluelScreenIntroCard(
                title: FluelCopy.archived(),
                subtitle: FluelCopy.archiveScreenSubtitle()
            )
            .listRowInsets(.init())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            VStack(
                alignment: .leading,
                spacing: FluelPresentationStyle.inlineSpacing
            ) {
                EntryContentFilterBar(
                    selection: contentFilterBinding
                )
                .popoverTip(
                    showsContentFiltersTip ? contentFiltersTip : nil,
                    arrowEdge: .top
                )

                if hasActiveSearch || hasActiveFilter {
                    FluelEntryListStateActions(
                        showsClearSearch: hasActiveSearch,
                        showsClearFilter: hasActiveFilter,
                        onClearSearch: clearSearch,
                        onClearFilter: clearFilter
                    )
                }
            }
            .fluelCard(tone: .muted)
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

            if showsListSummaryCards {
                FluelEntryListSummaryCard(summary: summary)
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

            ForEach(displayedEntries) { entry in
                NavigationLink {
                    EntryDetailView(entry: entry)
                        .navigationTransition(
                            .zoom(sourceID: entry.id, in: detailTransition)
                        )
                } label: {
                    EntryRowView(
                        entry: entry,
                        referenceDate: referenceDate,
                        footerText: entry.archivedAt.map { archivedAt in
                            EntryFormatting.archivedFooterText(
                                archivedAt: archivedAt,
                                note: showsNotePreviews
                                    ? entry.note
                                    : nil
                            )
                        },
                        showsMetadataBadges: showsMetadataBadges
                    )
                    .matchedTransitionSource(id: entry.id, in: detailTransition)
                }
                .swipeActions(
                    edge: .leading,
                    allowsFullSwipe: false
                ) {
                    Button {
                        restore(entry)
                    } label: {
                        Label(
                            FluelCopy.restore(),
                            systemImage: "arrow.uturn.backward"
                        )
                    }
                    .tint(.green)
                }
                .swipeActions(
                    edge: .trailing,
                    allowsFullSwipe: false
                ) {
                    Button(
                        role: .destructive
                    ) {
                        pendingDeleteEntry = entry
                    } label: {
                        Label(
                            FluelCopy.delete(),
                            systemImage: "trash"
                        )
                    }
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
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .fluelAppBackground()
    }

    private func restore(
        _ entry: Entry
    ) {
        Task {
            await mutationWorkflow.restore(entry: entry)
        }
    }

    private func clearSearch() {
        searchText = String()
    }

    private func clearFilter() {
        storedContentFilter = EntryContentFilterMode.all.rawValue
    }

    private func deletePendingEntry() {
        guard let pendingDeleteEntry else {
            return
        }

        self.pendingDeleteEntry = nil

        Task {
            await mutationWorkflow.delete(entry: pendingDeleteEntry)
        }
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    NavigationStack {
        ArchiveListView()
    }
    .fluelAppStyle()
}
