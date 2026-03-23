// swiftlint:disable closure_body_length closure_end_indentation
// swiftlint:disable file_length function_body_length opening_brace type_body_length
import FluelLibrary
import MHUI
import SwiftData
import SwiftUI
import TipKit

struct ArchiveListView: View {
    private enum Metrics {
        static let rowSpacing: CGFloat = 12
    }

    @Environment(\.mhTheme)
    private var theme
    @Environment(\.modelContext)
    private var context
    @Environment(FluelNoticeCenter.self)
    private var noticeCenter
    @Environment(FluelDisplayPreferencesStore.self)
    private var displayPreferences

    @Query(
        filter: #Predicate<Entry> { entry in
            entry.archivedAt != nil
        }
    )
    private var archivedEntries: [Entry]

    @State private var model = ArchiveScreenModel()
    @Namespace private var detailTransition

    private let contentFiltersTip = FluelTips.ContentFiltersTip()

    private var sortedEntries: [Entry] {
        EntryListOrdering.archived(
            archivedEntries,
            sortMode: model.sortMode
        )
    }

    private var displayedEntries: [Entry] {
        EntrySearchMatcher.filter(
            contentFilteredEntries,
            matching: model.searchText
        )
    }

    private var contentFilteredEntries: [Entry] {
        EntryContentFilter.filter(
            sortedEntries,
            mode: model.contentFilter
        )
    }

    private var summary: FluelEntryListSummary {
        .init(
            headline: FluelCopy.archivedEntryCount(sortedEntries.count),
            displayedEntries: displayedEntries,
            totalEntries: sortedEntries,
            sortLabel: FluelCopy.archivedSortMode(model.sortMode),
            filterLabel: FluelCopy.entryContentFilterMode(model.contentFilter)
        )
    }

    private var mutationWorkflow: FluelEntryMutationWorkflow {
        .init(
            context: context,
            surface: "ArchiveListView"
        )
    }

    private var showsContentFiltersTip: Bool {
        model.showsContentFiltersTip(
            sortedEntriesCount: sortedEntries.count,
            displayedEntriesCount: displayedEntries.count
        )
    }

    private var searchTextBinding: Binding<String> {
        .init(
            get: {
                model.searchText
            },
            set: { newValue in
                model.searchText = newValue
            }
        )
    }

    private var contentFilterBinding: Binding<EntryContentFilterMode> {
        .init(
            get: {
                model.contentFilter
            },
            set: { newValue in
                model.contentFilter = newValue
            }
        )
    }

    private var pendingDeleteBinding: Binding<Bool> {
        .init(
            get: {
                model.pendingDeleteEntry != nil
            },
            set: { isPresented in
                if isPresented == false {
                    model.dismissDeleteConfirmation()
                }
            }
        )
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 3_600)) { context in // swiftlint:disable:this no_magic_numbers
            Group {
                if sortedEntries.isEmpty {
                    emptyState
                } else if contentFilteredEntries.isEmpty {
                    filteredEmptyState
                } else if displayedEntries.isEmpty {
                    searchEmptyState
                } else {
                    listContent(referenceDate: context.date)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Section(FluelCopy.sort()) {
                        ForEach(ArchivedEntrySortMode.allCases, id: \.self) { mode in
                            Button {
                                model.sortMode = mode
                            } label: {
                                if model.sortMode == mode {
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
            text: searchTextBinding,
            prompt: FluelCopy.searchEntries()
        )
        .confirmationDialog(
            FluelCopy.deleteConfirmationTitle(),
            isPresented: pendingDeleteBinding,
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
                model.dismissDeleteConfirmation()
            }
        } message: {
            Text(
                FluelCopy.deleteConfirmationMessage(
                    for: model.pendingDeleteEntry?.title ?? String()
                )
            )
        }
        .alert(
            FluelCopy.error(),
            isPresented: Binding(
                get: {
                    model.errorMessage != nil
                },
                set: { isPresented in
                    if isPresented == false {
                        model.clearError()
                    }
                }
            )
        ) {
            Button(FluelCopy.ok(), role: .cancel) {
                model.clearError()
            }
        } message: {
            Text(model.errorMessage ?? String())
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(
                FluelCopy.archiveEmptyTitle(),
                systemImage: "archivebox"
            )
        } description: {
            Text(FluelCopy.archiveEmptyBody())
        }
        .mhEmptyStateLayout()
        .mhSurfaceInset()
        .mhSurface(role: .muted)
        .mhScreen(
            title: Text(FluelCopy.archived()),
            subtitle: Text(FluelCopy.archiveScreenSubtitle())
        )
    }

    private var searchEmptyState: some View {
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            listHeaderControls

            ContentUnavailableView {
                Label(
                    FluelCopy.archiveSearchEmptyTitle(),
                    systemImage: "magnifyingglass"
                )
            } description: {
                Text(FluelCopy.archiveSearchEmptyBody())
            }
            .mhEmptyStateLayout()
            .mhSurfaceInset()
            .mhSurface(role: .muted)
        }
        .mhScreen(
            title: Text(FluelCopy.archived()),
            subtitle: Text(FluelCopy.archiveScreenSubtitle())
        )
    }

    private var filteredEmptyState: some View {
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            listHeaderControls

            ContentUnavailableView {
                Label(
                    FluelCopy.archiveFilterEmptyTitle(),
                    systemImage: "line.3.horizontal.decrease.circle"
                )
            } description: {
                Text(FluelCopy.archiveFilterEmptyBody())
            }
            .mhEmptyStateLayout()
            .mhSurfaceInset()
            .mhSurface(role: .muted)
        }
        .mhScreen(
            title: Text(FluelCopy.archived()),
            subtitle: Text(FluelCopy.archiveScreenSubtitle())
        )
    }

    private var listHeaderControls: some View {
        VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
            EntryContentFilterBar(
                selection: contentFilterBinding
            )
            .popoverTip(
                showsContentFiltersTip ? contentFiltersTip : nil,
                arrowEdge: .top
            )

            if model.hasActiveSearch || model.hasActiveFilter {
                FluelEntryListStateActions(
                    showsClearSearch: model.hasActiveSearch,
                    showsClearFilter: model.hasActiveFilter,
                    onClearSearch: clearSearch,
                    onClearFilter: clearFilter
                )
            }
        }
    }

    private func listContent(
        referenceDate: Date
    ) -> some View {
        List {
            if displayPreferences.showsListSummaryCards {
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
                                note: displayPreferences.showsNotePreviews
                                    ? entry.note
                                    : nil
                            )
                        },
                        showsMetadataBadges: displayPreferences.showsMetadataBadges
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
                        model.confirmDelete(entry)
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
        .mhListChrome(
            title: Text(FluelCopy.archived()),
            subtitle: Text(FluelCopy.archiveScreenSubtitle())
        ) {
            listHeaderControls
        }
    }

    private func restore(
        _ entry: Entry
    ) {
        Task {
            let result = await mutationWorkflow.restore(entry: entry)
            model.handleMutationResult(
                result,
                noticeCenter: noticeCenter
            )
        }
    }

    private func clearSearch() {
        model.clearSearch()
    }

    private func clearFilter() {
        model.clearFilter()
    }

    private func deletePendingEntry() {
        guard let pendingDeleteEntry = model.pendingDeleteEntry else {
            return
        }

        model.dismissDeleteConfirmation()

        Task {
            let result = await mutationWorkflow.delete(entry: pendingDeleteEntry)
            model.handleMutationResult(
                result,
                noticeCenter: noticeCenter
            )
        }
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    NavigationStack {
        ArchiveListView()
    }
    .fluelPreviewEnvironment()
    .fluelAppStyle()
}
