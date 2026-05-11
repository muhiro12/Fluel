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
    let logger: MHLogger
    var calendar: Calendar = .autoupdatingCurrent
    var reloadTimelines: @MainActor () async throws -> Void = {
        FluelWidgetReloader.reloadAllTimelines()
    }

    func create(
        input: EntryFormInput
    ) async -> FluelMutationResult {
        let metadata = createOrUpdateMetadata(
            operation: "createEntry",
            input: input
        )

        logger.notice(
            "Entry mutation started",
            metadata: metadata("start", "pending")
        )

        return await runCreate(
            metadata: metadata
        ) {
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
        let metadata = createOrUpdateMetadata(
            operation: "updateEntry",
            input: input,
            entryID: entry.id
        )

        logger.notice(
            "Entry mutation started",
            metadata: metadata("start", "pending")
        )

        return await runVoid(
            metadata: metadata
        ) {
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
        let metadata = entryMetadata(
            operation: "archiveEntry",
            entry: entry
        )

        logger.notice(
            "Entry mutation started",
            metadata: metadata("start", "pending")
        )

        return await runVoid(
            metadata: metadata
        ) {
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
        let metadata = entryMetadata(
            operation: "restoreEntry",
            entry: entry
        )

        logger.notice(
            "Entry mutation started",
            metadata: metadata("start", "pending")
        )

        return await runVoid(
            metadata: metadata
        ) {
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
        let metadata = entryMetadata(
            operation: "deleteEntry",
            entry: entry
        )

        logger.notice(
            "Entry mutation started",
            metadata: metadata("start", "pending")
        )

        return await runVoid(
            metadata: metadata
        ) {
            try EntryRepository.delete(
                context: context,
                entry: entry
            )
        }
    }
}

private extension FluelEntryMutationWorkflow {
    typealias MutationMetadata = (_ phase: String, _ result: String) -> [String: String]

    func followUpSuccess(
        metadata: MutationMetadata
    ) async -> FluelMutationResult {
        do {
            try await reloadTimelines()
            logger.notice(
                "Entry mutation completed",
                metadata: metadata(
                    "completed",
                    "success"
                )
            )
            return .success
        } catch is CancellationError {
            logFailure(
                phase: .postCommitFollowUp,
                error: FollowUpError.reloadWidgetTimelines,
                metadata: metadata,
                followUp: "reloadWidgetTimelines",
                isWarning: true
            )
            return .degradedSuccess(
                message: FollowUpError.reloadWidgetTimelines.localizedDescription
            )
        } catch {
            logFailure(
                phase: .postCommitFollowUp,
                error: error,
                metadata: metadata,
                followUp: "reloadWidgetTimelines",
                isWarning: false
            )
            return .degradedSuccess(
                message: error.localizedDescription
            )
        }
    }

    func runCreate(
        metadata: MutationMetadata,
        operation: @MainActor @Sendable () throws -> Entry
    ) async -> FluelMutationResult {
        do {
            try Task.checkCancellation()
            _ = try operation()
            return await followUpSuccess(
                metadata: metadata
            )
        } catch is CancellationError {
            logger.warning(
                "Entry mutation cancelled",
                metadata: metadata(
                    FluelMutationFailurePhase.preflight.rawValue,
                    "cancelled"
                )
            )
            return .failure(
                .init(
                    phase: .preflight,
                    message: "The mutation was cancelled."
                )
            )
        } catch {
            logFailure(
                phase: .primaryMutation,
                error: error,
                metadata: metadata,
                followUp: nil,
                isWarning: false
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
        metadata: MutationMetadata,
        operation: @MainActor @Sendable () throws -> Void
    ) async -> FluelMutationResult {
        do {
            try Task.checkCancellation()
            try operation()
            return await followUpSuccess(
                metadata: metadata
            )
        } catch is CancellationError {
            logger.warning(
                "Entry mutation cancelled",
                metadata: metadata(
                    FluelMutationFailurePhase.preflight.rawValue,
                    "cancelled"
                )
            )
            return .failure(
                .init(
                    phase: .preflight,
                    message: "The mutation was cancelled."
                )
            )
        } catch {
            logFailure(
                phase: .primaryMutation,
                error: error,
                metadata: metadata,
                followUp: nil,
                isWarning: false
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
        phase: FluelMutationFailurePhase,
        error: Error,
        metadata: MutationMetadata,
        followUp: String?,
        isWarning: Bool
    ) {
        var failureMetadata = metadata(
            phase.rawValue,
            phase == .postCommitFollowUp ? "degradedSuccess" : "failure"
        )
        failureMetadata["error"] = error.localizedDescription

        if let followUp {
            failureMetadata["followUp"] = followUp
        }

        if isWarning {
            logger.warning(
                "Entry mutation failed",
                metadata: failureMetadata
            )
        } else {
            logger.error(
                "Entry mutation failed",
                metadata: failureMetadata
            )
        }
    }

    func createOrUpdateMetadata(
        operation: String,
        input: EntryFormInput,
        entryID: UUID? = nil
    ) -> MutationMetadata {
        let baseMetadata = [
            "operation": operation,
            "surface": surface,
            "entryID": entryID?.uuidString ?? "new",
            "startPrecision": input.startPrecision.rawValue,
            "hasPhoto": String(input.photoData?.isEmpty == false),
            "hasNote": String(input.note?.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty == false)
        ]

        return { phase, result in
            var metadata = baseMetadata
            metadata["phase"] = phase
            metadata["result"] = result
            return metadata
        }
    }

    func entryMetadata(
        operation: String,
        entry: Entry
    ) -> MutationMetadata {
        let baseMetadata = [
            "operation": operation,
            "surface": surface,
            "entryID": entry.id.uuidString,
            "startPrecision": entry.startPrecision.rawValue,
            "hasPhoto": String(entry.photoData?.isEmpty == false),
            "hasNote": String(entry.note?.isEmpty == false)
        ]

        return { phase, result in
            var metadata = baseMetadata
            metadata["phase"] = phase
            metadata["result"] = result
            return metadata
        }
    }
}
