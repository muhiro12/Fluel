import FluelLibrary
import MHUI
import SwiftData
import SwiftUI
import TipKit

struct HomeView: View {
    private enum Metrics {
        static let rowSpacing: CGFloat = 12
    }

    private enum TipKind {
        case addEntry
        case presets
        case filters
    }

    @Environment(\.mhTheme)
    private var theme
    @Environment(\.modelContext)
    private var context
    @EnvironmentObject private var presetStore: EntryPresetStore

    @Query(
        filter: #Predicate<Entry> { entry in
            entry.archivedAt == nil
        }
    )
    private var activeEntries: [Entry]

    @State private var errorMessage: String?
    @State private var searchText = String()
    @AppStorage(
        EntryListPreferences.homeSortMode,
        store: EntryListPreferences.store
    )
    private var storedSortMode = ActiveEntrySortMode.oldestFirst.rawValue
    @AppStorage(
        EntryListPreferences.homeContentFilter,
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

    let onAdd: () -> Void
    let onCreateFromPreset: (String) -> Void
    let onShowArchive: () -> Void
    let onShowLicenses: () -> Void

    private let entryCreationTip = FluelTips.EntryCreationTip()
    private let presetSelectionTip = FluelTips.PresetSelectionTip()
    private let contentFiltersTip = FluelTips.ContentFiltersTip()

    private var sortedEntries: [Entry] {
        EntryListOrdering.active(
            activeEntries,
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

    private var sortMode: ActiveEntrySortMode {
        ActiveEntrySortMode(rawValue: storedSortMode) ?? .oldestFirst
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
            headline: FluelCopy.activeEntryCount(sortedEntries.count),
            displayedEntries: displayedEntries,
            totalEntries: sortedEntries,
            sortLabel: FluelCopy.activeSortMode(sortMode),
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

    private var quickPresets: [EntryPreset] {
        presetStore.suggestedPresets(limit: 4)
    }

    private var currentTip: TipKind? {
        guard FluelTipBootstrap.isEnabled else {
            return nil
        }

        if FluelTipState.hasLearnedEntryCreation == false {
            return .addEntry
        }

        if quickPresets.isEmpty == false,
           FluelTipState.hasLearnedPresetSelection == false {
            return .presets
        }

        if sortedEntries.isEmpty == false,
           displayedEntries.isEmpty == false,
           FluelTipState.hasLearnedContentFilters == false {
            return .filters
        }

        return nil
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Section(FluelCopy.sort()) {
                        ForEach(ActiveEntrySortMode.allCases, id: \.self) { mode in
                            Button {
                                storedSortMode = mode.rawValue
                            } label: {
                                if sortMode == mode {
                                    Label(
                                        FluelCopy.activeSortMode(mode),
                                        systemImage: "checkmark"
                                    )
                                } else {
                                    Text(
                                        FluelCopy.activeSortMode(mode)
                                    )
                                }
                            }
                        }
                    }

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
                .popoverTip(
                    currentTip == .addEntry ? entryCreationTip : nil,
                    arrowEdge: .top
                )
            }
        }
        .searchable(
            text: $searchText,
            prompt: FluelCopy.searchEntries()
        )
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
            VStack(alignment: .leading, spacing: theme.spacing.section) {
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

                if quickPresets.isEmpty == false {
                    quickPresetsCard
                        .mhRow()
                        .mhSurface(role: .muted)
                }
            }
            .mhSurfaceInset()
        }
        .mhScreen(
            title: Text(FluelAppConfiguration.appName),
            subtitle: Text(FluelCopy.homeScreenSubtitle())
        )
    }

    private var searchEmptyState: some View {
        ContentUnavailableView {
            Label(
                FluelCopy.homeSearchEmptyTitle(),
                systemImage: "magnifyingglass"
            )
        } description: {
            Text(FluelCopy.homeSearchEmptyBody())
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
            if quickPresets.isEmpty == false {
                quickPresetsCard
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
                } label: {
                    EntryRowView(
                        entry: entry,
                        referenceDate: referenceDate,
                        footerText: showsNotePreviews
                            ? EntryFormatting.notePreviewText(
                                entry.note
                            )
                            : nil,
                        showsMetadataBadges: showsMetadataBadges
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
        ) {
            VStack(alignment: .leading, spacing: theme.spacing.inline) {
                EntryContentFilterBar(
                    selection: contentFilterBinding
                )
                .popoverTip(
                    currentTip == .filters ? contentFiltersTip : nil,
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
        }
    }

    private func archive(
        _ entry: Entry
    ) {
        Task {
            await mutationWorkflow.archive(entry: entry)
        }
    }

    var quickPresetsCard: some View {
        EntryPresetStrip(
            presets: quickPresets,
            selectedPresetID: nil,
            onSelect: selectPreset
        )
        .popoverTip(
            currentTip == .presets ? presetSelectionTip : nil,
            arrowEdge: .top
        )
    }

    func selectPreset(
        _ preset: EntryPreset
    ) {
        FluelTipState.markPresetSelectionLearned()
        presetStore.markUsed(preset.id)
        onCreateFromPreset(preset.id)
    }

    private func clearSearch() {
        searchText = String()
    }

    private func clearFilter() {
        storedContentFilter = EntryContentFilterMode.all.rawValue
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    NavigationStack {
        HomeView(
            onAdd: {},
            onCreateFromPreset: { _ in },
            onShowArchive: {},
            onShowLicenses: {}
        )
    }
    .environmentObject(EntryPresetStore.preview())
    .fluelAppStyle()
}
