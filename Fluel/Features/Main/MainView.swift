import FluelLibrary
import SwiftData
import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            Tab(
                FluelCopy.home(),
                systemImage: "house"
            ) {
                HomeTabRootView()
            }

            Tab(
                FluelCopy.timeline(),
                systemImage: "clock"
            ) {
                TimelineTabRootView()
            }

            Tab(
                FluelCopy.dashboard(),
                systemImage: "square.grid.2x2"
            ) {
                DashboardTabRootView()
            }

            Tab(
                FluelCopy.settings(),
                systemImage: "gearshape"
            ) {
                SettingsTabRootView()
            }
        }
    }
}

private enum MainDestination: Hashable {
    case archive
}

private enum MainSheet: Identifiable {
    case create(presetID: String?)
    case licenses

    var id: String {
        switch self {
        case let .create(presetID):
            if let presetID {
                return "create-\(presetID)"
            }

            return "create"
        case .licenses:
            return "licenses"
        }
    }
}

private struct HomeTabRootView: View {
    @Environment(EntryPresetStore.self)
    private var presetStore

    @State private var path = [MainDestination]()
    @State private var activeSheet: MainSheet?

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                onAdd: presentCreateEntry,
                onCreateFromPreset: presentCreateEntry(presetID:),
                onShowArchive: showArchive,
                onShowLicenses: showLicenses
            )
            .navigationDestination(for: MainDestination.self) { destination in
                switch destination {
                case .archive:
                    ArchiveListView()
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            MainSheetView(sheet: sheet)
        }
    }
}

private extension HomeTabRootView {
    func presentCreateEntry() {
        presentCreateEntry(
            presetID: presetStore.defaultCreatePresetID
        )
    }

    func presentCreateEntry(
        presetID: String?
    ) {
        FluelTipState.markEntryCreationLearned()
        activeSheet = .create(presetID: presetID)
    }

    func showArchive() {
        path.append(.archive)
    }

    func showLicenses() {
        activeSheet = .licenses
    }
}

private struct TimelineTabRootView: View {
    @Environment(EntryPresetStore.self)
    private var presetStore

    @State private var activeSheet: MainSheet?

    var body: some View {
        NavigationStack {
            ActivityTimelineView(
                onAdd: presentCreateEntry
            )
        }
        .sheet(item: $activeSheet) { sheet in
            MainSheetView(sheet: sheet)
        }
    }
}

private extension TimelineTabRootView {
    func presentCreateEntry() {
        FluelTipState.markEntryCreationLearned()
        activeSheet = .create(
            presetID: presetStore.defaultCreatePresetID
        )
    }
}

private struct DashboardTabRootView: View {
    @Environment(EntryPresetStore.self)
    private var presetStore

    @State private var path = [MainDestination]()
    @State private var activeSheet: MainSheet?

    var body: some View {
        NavigationStack(path: $path) {
            DashboardView(
                onAdd: presentCreateEntry,
                onCreateFromPreset: presentCreateEntry(presetID:),
                onShowArchive: showArchive,
                onShowLicenses: showLicenses
            )
            .navigationDestination(for: MainDestination.self) { destination in
                switch destination {
                case .archive:
                    ArchiveListView()
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            MainSheetView(sheet: sheet)
        }
    }
}

private extension DashboardTabRootView {
    func presentCreateEntry() {
        presentCreateEntry(
            presetID: presetStore.defaultCreatePresetID
        )
    }

    func presentCreateEntry(
        presetID: String?
    ) {
        FluelTipState.markEntryCreationLearned()
        activeSheet = .create(presetID: presetID)
    }

    func showArchive() {
        path.append(.archive)
    }

    func showLicenses() {
        activeSheet = .licenses
    }
}

private struct SettingsTabRootView: View {
    @State private var path = [MainDestination]()
    @State private var activeSheet: MainSheet?

    var body: some View {
        NavigationStack(path: $path) {
            SettingsView(
                onShowArchive: showArchive,
                onShowLicenses: showLicenses
            )
            .navigationDestination(for: MainDestination.self) { destination in
                switch destination {
                case .archive:
                    ArchiveListView()
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            MainSheetView(sheet: sheet)
        }
    }
}

private extension SettingsTabRootView {
    func showArchive() {
        path.append(.archive)
    }

    func showLicenses() {
        activeSheet = .licenses
    }
}

private struct MainSheetView: View {
    @Environment(EntryPresetStore.self)
    private var presetStore

    let sheet: MainSheet

    var body: some View {
        NavigationStack {
            switch sheet {
            case let .create(presetID):
                EntryFormView(
                    mode: .create,
                    prefilledInput: presetID.flatMap { presetStore.resolvedInput(for: $0) },
                    initialPresetID: presetID
                )
            case .licenses:
                FluelLicenseView()
            }
        }
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    @Previewable var presetStore = EntryPresetStore.preview()

    if let context = try? FluelSampleData.makeSharedContext() {
        MainView()
            .modelContainer(context.modelContainer)
            .environment(presetStore)
            .fluelAppStyle()
    } else {
        Text(FluelCopy.failedToLoadPreview())
    }
}
