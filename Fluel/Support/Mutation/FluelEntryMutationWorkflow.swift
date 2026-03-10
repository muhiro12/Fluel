import FluelLibrary
import Foundation
import MHPlatform
import SwiftData

@MainActor
struct FluelEntryMutationWorkflow {
    let context: ModelContext
    var calendar: Calendar = .autoupdatingCurrent
    var onSuccess: @MainActor () -> Void = {}
    var onError: @MainActor (String) -> Void = { _ in }

    func create(
        input: EntryFormInput
    ) async {
        await runCreate(name: "createEntry") {
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
    ) async {
        await runVoid(name: "updateEntry") {
            try EntryRepository.update(
                context: context,
                entry: entry,
                input: input,
                now: .now,
                calendar: calendar
            )
        }
    }

    func archive(
        entry: Entry
    ) async {
        await runVoid(name: "archiveEntry") {
            try EntryRepository.archive(
                context: context,
                entry: entry,
                now: .now
            )
        }
    }

    func restore(
        entry: Entry
    ) async {
        await runVoid(name: "restoreEntry") {
            try EntryRepository.restore(
                context: context,
                entry: entry,
                now: .now
            )
        }
    }

    func delete(
        entry: Entry
    ) async {
        await runVoid(name: "deleteEntry") {
            try EntryRepository.delete(
                context: context,
                entry: entry
            )
        }
    }
}

private extension FluelEntryMutationWorkflow {
    var successAdapter: MHMutationAdapter<Void> {
        .fixed {
            MHMutationStep.mainActor(name: "reloadWidgetTimelines") {
                FluelWidgetReloader.reloadAllTimelines()
            }
            MHMutationStep.mainActor(name: "handleMutationSuccess") {
                onSuccess()
            }
        }
    }

    func runCreate(
        name: String,
        operation: @escaping @MainActor @Sendable () throws -> Entry
    ) async {
        do {
            _ = try await MHMutationWorkflow.runThrowing(
                name: name,
                operation: operation,
                adapter: successAdapter,
                projection: .closures(
                    afterSuccess: { _ in () },
                    returning: { _ in () }
                )
            )
        } catch is CancellationError {
            return
        } catch let error as MHMutationWorkflowError {
            onError(error.localizedDescription)
        } catch {
            onError(error.localizedDescription)
        }
    }

    func runVoid(
        name: String,
        operation: @escaping @MainActor @Sendable () throws -> Void
    ) async {
        do {
            _ = try await MHMutationWorkflow.runThrowing(
                name: name,
                operation: operation,
                adapter: successAdapter,
                adapterValue: ()
            )
        } catch is CancellationError {
            return
        } catch let error as MHMutationWorkflowError {
            onError(error.localizedDescription)
        } catch {
            onError(error.localizedDescription)
        }
    }
}
