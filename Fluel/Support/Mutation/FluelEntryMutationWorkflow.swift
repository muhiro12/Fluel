import FluelLibrary
import Foundation
import MHPlatform
import SwiftData

@MainActor
struct FluelEntryMutationWorkflow {
    private enum FollowUpError: LocalizedError {
        case reloadWidgetTimelines

        var errorDescription: String? {
            "Widget timelines could not be refreshed."
        }
    }

    let context: ModelContext
    let surface: String
    var calendar: Calendar = .autoupdatingCurrent
    var reloadTimelines: @MainActor () async throws -> Void = {
        FluelWidgetReloader.reloadAllTimelines()
    }

    private let logger = FluelAppLogging.logger(
        category: "EntryMutation"
    )

    func create(
        input: EntryFormInput
    ) async -> FluelMutationResult {
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
    ) async -> FluelMutationResult {
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
    ) async -> FluelMutationResult {
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
    ) async -> FluelMutationResult {
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
    ) async -> FluelMutationResult {
        await runVoid(name: "deleteEntry") {
            try EntryRepository.delete(
                context: context,
                entry: entry
            )
        }
    }
}

private extension FluelEntryMutationWorkflow {
    func followUpSuccess() async -> FluelMutationResult {
        do {
            try await reloadTimelines()
            return .success
        } catch is CancellationError {
            logFailure(
                name: "reloadWidgetTimelines",
                phase: .postCommitFollowUp,
                error: FollowUpError.reloadWidgetTimelines
            )
            return .degradedSuccess(
                message: FollowUpError.reloadWidgetTimelines.localizedDescription
            )
        } catch {
            logFailure(
                name: "reloadWidgetTimelines",
                phase: .postCommitFollowUp,
                error: error
            )
            return .degradedSuccess(
                message: error.localizedDescription
            )
        }
    }

    func runCreate(
        name: String,
        operation: @MainActor @Sendable () throws -> Entry
    ) async -> FluelMutationResult {
        do {
            try Task.checkCancellation()
            _ = try operation()
            return await followUpSuccess()
        } catch is CancellationError {
            return .failure(
                .init(
                    phase: .preflight,
                    message: "The mutation was cancelled."
                )
            )
        } catch {
            logFailure(
                name: name,
                phase: .primaryMutation,
                error: error
            )
            return .failure(
                .init(
                    phase: .primaryMutation,
                    message: error.localizedDescription
                )
            )
        }
    }

    func runVoid(
        name: String,
        operation: @MainActor @Sendable () throws -> Void
    ) async -> FluelMutationResult {
        do {
            try Task.checkCancellation()
            try operation()
            return await followUpSuccess()
        } catch is CancellationError {
            return .failure(
                .init(
                    phase: .preflight,
                    message: "The mutation was cancelled."
                )
            )
        } catch {
            logFailure(
                name: name,
                phase: .primaryMutation,
                error: error
            )
            return .failure(
                .init(
                    phase: .primaryMutation,
                    message: error.localizedDescription
                )
            )
        }
    }

    func logFailure(
        name: String,
        phase: FluelMutationFailurePhase,
        error: Error
    ) {
        let message =
            "Entry mutation failed. operation=\(name) surface=\(surface) " +
            "phase=\(phase.rawValue) error=\(error.localizedDescription)"

        logger.error(
            message
        )
    }
}
