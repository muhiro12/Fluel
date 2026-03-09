import FluelLibrary
import MHLogging
import MHPlatform
import SwiftData
import SwiftUI

@main
struct FluelApp: App {
    private let modelContainer: ModelContainer
    private let appBootstrap: MHAppRuntimeBootstrap
    private let captureBootstrap: CodexCaptureBootstrap?
    private let startupLogger = FluelAppLogging.logger(category: "AppStartup")

    var body: some Scene {
        WindowGroup {
            Group {
                if let captureBootstrap {
                    CodexCaptureRootView(bootstrap: captureBootstrap)
                        .environmentObject(captureBootstrap.presetStore)
                } else {
                    MainView()
                }
            }
            .modelContainer(modelContainer)
            .mhAppRuntimeBootstrap(appBootstrap)
            .fluelAppStyle()
        }
    }

    @MainActor
    init() {
        startupLogger.notice("app startup began")

#if DEBUG
        if let bootstrap = try? CodexCaptureBootstrap.current() {
            captureBootstrap = bootstrap
            modelContainer = bootstrap.modelContainer
        } else {
            captureBootstrap = nil
            modelContainer = Self.makeLiveModelContainer()
        }
#else
        captureBootstrap = nil
        modelContainer = Self.makeLiveModelContainer()
#endif
        appBootstrap = .init(
            configuration: FluelAppConfiguration.runtimeConfiguration,
            lifecyclePlan: FluelAppConfiguration.runtimeLifecyclePlan
        )

        startupLogger.notice("startup dependencies ready")
        startupLogger.notice("startup wiring finished")
    }
}

private extension FluelApp {
    static func makeLiveModelContainer() -> ModelContainer {
        do {
            return try ModelContainerFactory.shared()
        } catch {
            preconditionFailure("Failed to initialize model container: \(error)")
        }
    }
}

private struct CodexCaptureBootstrap {
    let screen: CodexCaptureScreen
    let modelContainer: ModelContainer
    let presetStore: EntryPresetStore
    let sampleEntry: Entry?

    @MainActor
    static func current() throws -> Self? {
        let arguments = ProcessInfo.processInfo.arguments

        guard let flagIndex = arguments.firstIndex(
            of: "--codex-capture-screen"
        ) else {
            return nil
        }

        let valueIndex = arguments.index(after: flagIndex)

        guard arguments.indices.contains(valueIndex),
              let screen = CodexCaptureScreen(
                  rawValue: arguments[valueIndex]
              ) else {
            return nil
        }

        let sampleContext = try FluelSampleData.makeSharedContext()
        let entries = try sampleContext.modelContainer.mainContext.fetch(
            FetchDescriptor<Entry>()
        )

        return .init(
            screen: screen,
            modelContainer: sampleContext.modelContainer,
            presetStore: EntryPresetStore.preview(),
            sampleEntry: EntryListOrdering.active(entries).first ?? entries.first
        )
    }
}

private enum CodexCaptureScreen: String {
    case main
    case home
    case timeline
    case dashboard
    case archive
    case detail
    case formCreate
    case formEdit
    case settings
    case presetSettings
    case presetEditor
    case licenses
}

private struct CodexCaptureRootView: View {
    let bootstrap: CodexCaptureBootstrap

    @ViewBuilder
    var body: some View {
        switch bootstrap.screen {
        case .main:
            MainView()
        case .home:
            NavigationStack {
                HomeView(
                    onAdd: {},
                    onCreateFromPreset: { _ in },
                    onShowArchive: {},
                    onShowLicenses: {}
                )
            }
        case .timeline:
            NavigationStack {
                ActivityTimelineView(
                    onAdd: {}
                )
            }
        case .dashboard:
            NavigationStack {
                DashboardView(
                    onAdd: {},
                    onCreateFromPreset: { _ in },
                    onShowArchive: {},
                    onShowLicenses: {}
                )
            }
        case .archive:
            NavigationStack {
                ArchiveListView()
            }
        case .detail:
            if let sampleEntry = bootstrap.sampleEntry {
                NavigationStack {
                    EntryDetailView(entry: sampleEntry)
                }
            } else {
                Text("Missing sample entry")
            }
        case .formCreate:
            NavigationStack {
                EntryFormView(
                    mode: .create
                )
            }
        case .formEdit:
            if let sampleEntry = bootstrap.sampleEntry {
                NavigationStack {
                    EntryFormView(
                        mode: .edit(sampleEntry)
                    )
                }
            } else {
                Text("Missing sample entry")
            }
        case .settings:
            NavigationStack {
                SettingsView(
                    onShowArchive: {},
                    onShowLicenses: {}
                )
            }
        case .presetSettings:
            NavigationStack {
                PresetSettingsView()
            }
        case .presetEditor:
            NavigationStack {
                PresetEditorView(mode: .create) { _ in }
            }
        case .licenses:
            NavigationStack {
                FluelLicenseView()
            }
        }
    }
}
