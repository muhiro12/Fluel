import SwiftUI

struct TimelineTabRootView: View {
    @Environment(EntryPresetStore.self)
    private var presetStore

    let router: MainTabRouter

    var body: some View {
        NavigationStack {
            ActivityTimelineView(
                onAdd: presentCreateEntry
            )
        }
        .sheet(item: timelineSheetBinding) { sheet in
            MainSheetView(sheet: sheet)
        }
    }

    private var timelineSheetBinding: Binding<MainSheetRoute?> {
        .init(
            get: {
                router.timelineSheet
            },
            set: { newValue in
                router.timelineSheet = newValue
            }
        )
    }

    private func presentCreateEntry() {
        FluelTipState.markEntryCreationLearned()
        router.presentTimelineCreate(
            presetID: presetStore.defaultCreatePresetID
        )
    }
}
