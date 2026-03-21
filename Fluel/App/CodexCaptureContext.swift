import FluelLibrary
import Foundation
import SwiftData

@MainActor
struct CodexCaptureContext {
    enum Screen: String {
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

    let screen: Screen
    let modelContainer: ModelContainer
    let presetStore: EntryPresetStore
    let sampleEntry: Entry?

    static func current() throws -> Self? {
        let arguments = ProcessInfo.processInfo.arguments

        guard let flagIndex = arguments.firstIndex(
            of: "--codex-capture-screen"
        ) else {
            return nil
        }

        let valueIndex = arguments.index(after: flagIndex)

        guard arguments.indices.contains(valueIndex),
              let screen = Screen(
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
