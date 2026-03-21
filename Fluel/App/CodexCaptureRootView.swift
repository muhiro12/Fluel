import SwiftUI

struct CodexCaptureRootView: View {
    let context: CodexCaptureContext

    @ViewBuilder var body: some View {
        switch context.screen {
        case .main:
            MainView()
        case .home:
            NavigationStack {
                HomeView(
                    onAdd: { () },
                    onCreateFromPreset: { _ in () },
                    onShowArchive: { () },
                    onShowLicenses: { () }
                )
            }
        case .timeline:
            NavigationStack {
                ActivityTimelineView { () }
            }
        case .dashboard:
            NavigationStack {
                DashboardView(
                    onAdd: { () },
                    onCreateFromPreset: { _ in () },
                    onShowArchive: { () },
                    onShowLicenses: { () }
                )
            }
        case .archive:
            NavigationStack {
                ArchiveListView()
            }
        case .detail:
            if let sampleEntry = context.sampleEntry {
                NavigationStack {
                    EntryDetailView(entry: sampleEntry)
                }
            } else {
                Text(FluelCopy.missingSampleEntry())
            }
        case .formCreate:
            NavigationStack {
                EntryFormView(
                    mode: .create
                )
            }
        case .formEdit:
            if let sampleEntry = context.sampleEntry {
                NavigationStack {
                    EntryFormView(
                        mode: .edit(sampleEntry)
                    )
                }
            } else {
                Text(FluelCopy.missingSampleEntry())
            }
        case .settings:
            NavigationStack {
                SettingsView(
                    onShowArchive: { () },
                    onShowLicenses: { () }
                )
            }
        case .presetSettings:
            NavigationStack {
                PresetSettingsView()
            }
        case .presetEditor:
            NavigationStack {
                PresetEditorView(mode: .create) { _ in () }
            }
        case .licenses:
            NavigationStack {
                FluelLicenseView()
            }
        }
    }
}
