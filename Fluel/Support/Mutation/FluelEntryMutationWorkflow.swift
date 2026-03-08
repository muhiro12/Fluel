import FluelLibrary
import Foundation
import SwiftData

@MainActor
struct FluelEntryMutationWorkflow {
    let context: ModelContext
    var calendar: Calendar = .autoupdatingCurrent
    var onSuccess: @MainActor () -> Void = {}
    var onError: @MainActor (String) -> Void = { _ in }

    @discardableResult
    func create(
        input: EntryFormInput
    ) -> Entry? {
        perform {
            try EntryRepository.create(
                context: context,
                input: input,
                now: .now,
                calendar: calendar
            )
        }
    }

    func update(
        entry: Entry,
        input: EntryFormInput
    ) {
        _ = perform {
            try EntryRepository.update(
                context: context,
                entry: entry,
                input: input,
                now: .now,
                calendar: calendar
            )
        } as Void?
    }

    func archive(
        entry: Entry
    ) {
        _ = perform {
            try EntryRepository.archive(
                context: context,
                entry: entry,
                now: .now
            )
        } as Void?
    }

    func restore(
        entry: Entry
    ) {
        _ = perform {
            try EntryRepository.restore(
                context: context,
                entry: entry,
                now: .now
            )
        } as Void?
    }

    func delete(
        entry: Entry
    ) {
        _ = perform {
            try EntryRepository.delete(
                context: context,
                entry: entry
            )
        } as Void?
    }
}

private extension FluelEntryMutationWorkflow {
    func perform<Value>(
        _ operation: () throws -> Value
    ) -> Value? {
        do {
            let value = try operation()
            handleSuccess()
            return value
        } catch {
            onError(error.localizedDescription)
            return nil
        }
    }

    func handleSuccess() {
        // Keep post-save side effects behind one app-side boundary.
        FluelWidgetReloader.reloadAllTimelines()
        onSuccess()
    }
}
