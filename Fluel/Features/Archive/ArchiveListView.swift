import FluelLibrary
import MHUI
import SwiftData
import SwiftUI

struct ArchiveListView: View {
    private enum Metrics {
        static let rowSpacing: CGFloat = 12
    }

    @Environment(\.mhTheme)
    private var theme
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
            }
        )
    }

    private var hasActiveSearch: Bool {
        searchText.isEmpty == false
    }

    private var hasActiveFilter: Bool {
        contentFilter != .all
    }

    private var displayedNoteCount: Int {
        displayedEntries.reduce(into: 0) { partialResult, entry in
            if EntryFormatting.notePreviewText(entry.note) != nil {
                partialResult += 1
            }
        }
    }

    private var displayedPhotoCount: Int {
        displayedEntries.reduce(into: 0) { partialResult, entry in
            if entry.photoData?.isEmpty == false {
                partialResult += 1
            }
        }
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
            .navigationBarTitleDisplayMode(.inline)
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
        .mhScreen(
            title: Text(FluelCopy.archived()),
            subtitle: Text(FluelCopy.archiveScreenSubtitle())
        )
    }

    private func listContent(
        referenceDate: Date
    ) -> some View {
        List {
            if showsListSummaryCards {
                listSummaryCard
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
        .mhListChrome(
            title: Text(FluelCopy.archived()),
            subtitle: Text(FluelCopy.archiveScreenSubtitle())
        ) {
            VStack(alignment: .leading, spacing: theme.spacing.inline) {
                EntryContentFilterBar(
                    selection: contentFilterBinding
                )

                if hasActiveSearch || hasActiveFilter {
                    listStateActions
                }
            }
        }
    }

    private var listSummaryCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(
                FluelCopy.archivedEntryCount(
                    sortedEntries.count
                )
            )
            .font(.headline)

            Text(
                FluelCopy.showingEntries(
                    displayedCount: displayedEntries.count,
                    totalCount: sortedEntries.count
                )
            )
            .font(.subheadline)

            Text(
                FluelCopy.withNotesCount(
                    displayedNoteCount
                )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(
                FluelCopy.withPhotosCount(
                    displayedPhotoCount
                )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(
                "\(FluelCopy.sort()): \(FluelCopy.archivedSortMode(sortMode))"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(
                "\(FluelCopy.filter()): \(FluelCopy.entryContentFilterMode(contentFilter))"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhRow()
        .mhSurface(role: .muted)
    }

    private var listStateActions: some View {
        HStack(spacing: theme.spacing.inline) {
            if hasActiveSearch {
                Button(
                    FluelCopy.clearSearch(),
                    action: clearSearch
                )
                .buttonStyle(.mhSecondary)
            }

            if hasActiveFilter {
                Button(
                    FluelCopy.clearFilter(),
                    action: clearFilter
                )
                .buttonStyle(.mhSecondary)
            }

            Spacer(minLength: 0)
        }
        .mhSurfaceInset()
        .mhSurface(role: .muted)
    }

    private func restore(
        _ entry: Entry
    ) {
        do {
            try EntryRepository.restore(
                context: context,
                entry: entry
            )
            FluelWidgetReloader.reloadAllTimelines()
        } catch {
            errorMessage = error.localizedDescription
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

        do {
            try EntryRepository.delete(
                context: context,
                entry: pendingDeleteEntry
            )
            FluelWidgetReloader.reloadAllTimelines()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    NavigationStack {
        ArchiveListView()
    }
    .fluelAppStyle()
}
