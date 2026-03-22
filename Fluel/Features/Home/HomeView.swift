import FluelLibrary
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

    @Environment(\.modelContext)
    private var context
    @Environment(EntryPresetStore.self)
    private var presetStore

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
    @Namespace private var detailTransition

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
        .navigationTitle(FluelAppConfiguration.appName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
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
                    title: nil,
                    subtitle: FluelCopy.homeScreenSubtitle()
                )

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
                    .buttonStyle(.borderedProminent)
                }
                .fluelCard(tone: .muted)

                if quickPresets.isEmpty == false {
                    quickPresetsCard
                        .fluelCard(tone: .muted)
                }
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
                    title: nil,
                    subtitle: FluelCopy.homeScreenSubtitle()
                )

                ContentUnavailableView {
                    Label(
                        FluelCopy.homeSearchEmptyTitle(),
                        systemImage: "magnifyingglass"
                    )
                } description: {
                    Text(FluelCopy.homeSearchEmptyBody())
                }
                .fluelCard()
            }
            .padding(FluelPresentationStyle.screenPadding)
        }
        .fluelAppBackground()
        .fluelPrimarySearchable(
            text: $searchText,
            prompt: FluelCopy.searchEntries()
        )
    }

    private func listContent(
        referenceDate: Date
    ) -> some View {
        List {
            FluelScreenIntroCard(
                title: nil,
                subtitle: FluelCopy.homeScreenSubtitle()
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

            if quickPresets.isEmpty == false {
                quickPresetsCard
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
                        .navigationTransition(
                            .zoom(sourceID: entry.id, in: detailTransition)
                        )
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
                    .matchedTransitionSource(id: entry.id, in: detailTransition)
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
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .fluelAppBackground()
        .fluelPrimarySearchable(
            text: $searchText,
            prompt: FluelCopy.searchEntries()
        )
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
    @Previewable var presetStore = EntryPresetStore.preview()

    NavigationStack {
        HomeView(
            onAdd: {},
            onCreateFromPreset: { _ in },
            onShowArchive: {},
            onShowLicenses: {}
        )
    }
    .environment(presetStore)
    .fluelAppStyle()
}
