// swiftlint:disable closure_body_length closure_end_indentation
// swiftlint:disable file_length function_body_length no_empty_block
// swiftlint:disable no_magic_numbers opening_brace type_body_length
// swiftlint:disable type_contents_order
import FluelLibrary
import MHUI
import SwiftData
import SwiftUI
import TipKit

struct HomeView: View {
    private enum Metrics {
        static let rowSpacing: CGFloat = 12
    }

    @Environment(\.mhTheme)
    private var theme
    @Environment(\.modelContext)
    private var context
    @Environment(EntryPresetStore.self)
    private var presetStore
    @Environment(FluelNoticeCenter.self)
    private var noticeCenter
    @Environment(FluelDisplayPreferencesStore.self)
    private var displayPreferences

    @Query(
        filter: #Predicate<Entry> { entry in
            entry.archivedAt == nil
        }
    )
    private var activeEntries: [Entry]

    @State private var model = HomeScreenModel()
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
            headline: FluelCopy.activeEntryCount(sortedEntries.count),
            displayedEntries: displayedEntries,
            totalEntries: sortedEntries,
            sortLabel: FluelCopy.activeSortMode(model.sortMode),
            filterLabel: FluelCopy.entryContentFilterMode(model.contentFilter)
        )
    }

    private var mutationWorkflow: FluelEntryMutationWorkflow {
        .init(
            context: context,
            surface: "HomeView"
        )
    }

    private var quickPresets: [EntryPreset] {
        presetStore.suggestedPresets(limit: 4)
    }

    private var currentTip: HomeScreenModel.TipKind? {
        model.currentTip(
            hasQuickPresets: quickPresets.isEmpty == false,
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
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Section(FluelCopy.sort()) {
                        ForEach(ActiveEntrySortMode.allCases, id: \.self) { mode in
                            Button {
                                model.sortMode = mode
                            } label: {
                                if model.sortMode == mode {
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
            text: searchTextBinding,
            prompt: FluelCopy.searchEntries()
        )
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
        ScrollView {
            VStack(alignment: .leading, spacing: theme.fluelSectionSpacing) {
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
                        footerText: displayPreferences.showsNotePreviews
                            ? EntryFormatting.notePreviewText(
                                entry.note
                            )
                            : nil,
                        showsMetadataBadges: displayPreferences.showsMetadataBadges
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
        .mhListChrome(
            title: Text(FluelAppConfiguration.appName),
            subtitle: Text(FluelCopy.homeScreenSubtitle())
        ) {
            VStack(alignment: .leading, spacing: theme.fluelInlineSpacing) {
                EntryContentFilterBar(
                    selection: contentFilterBinding
                )
                .popoverTip(
                    currentTip == .filters ? contentFiltersTip : nil,
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
    }

    private func archive(
        _ entry: Entry
    ) {
        Task {
            let result = await mutationWorkflow.archive(entry: entry)
            model.handleMutationResult(
                result,
                noticeCenter: noticeCenter
            )
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
        model.clearSearch()
    }

    private func clearFilter() {
        model.clearFilter()
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
    .fluelPreviewEnvironment(presetStore: presetStore)
    .fluelAppStyle()
}
