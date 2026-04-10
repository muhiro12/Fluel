@testable import Fluel
import FluelLibrary
import Foundation
import SwiftData
import Testing

@MainActor
struct FluelEntryMutationWorkflowTests {
    @Test
    func create_persists_entry_and_returns_success() async throws {
        let context = try makeTestContext()
        let logProbe = FluelLogProbe()
        var reloadCallCount = 0
        let reloadTimelines: @MainActor () async -> Void = {
            reloadCallCount += 1
        }

        let workflow = FluelEntryMutationWorkflow(
            context: context,
            surface: "test",
            logger: logProbe.logger(category: "EntryMutation"),
            reloadTimelines: reloadTimelines
        )

        let result = await workflow.create(
            input: .init(
                title: "Wallet",
                startPrecision: .year,
                startYear: 2_020
            )
        )

        let entries = try context.fetch(FetchDescriptor<Entry>())

        #expect(entries.count == 1)
        #expect(entries.first?.title == "Wallet")
        #expect(result == .success)
        #expect(reloadCallCount == 1)

        let events = await recordedEvents(
            from: logProbe
        )
        let startedEvent = try #require(events.first { event in
            event.message == "Entry mutation started"
        })
        let completedEvent = try #require(events.first { event in
            event.message == "Entry mutation completed"
        })

        #expect(startedEvent.metadata["operation"] == "createEntry")
        #expect(startedEvent.metadata["surface"] == "test")
        #expect(startedEvent.metadata["result"] == "pending")
        #expect(completedEvent.metadata["phase"] == "completed")
        #expect(completedEvent.metadata["result"] == "success")
    }

    @Test
    func create_surfaces_validation_error_without_follow_up() async throws {
        let context = try makeTestContext()
        let logProbe = FluelLogProbe()
        var reloadCallCount = 0
        let reloadTimelines: @MainActor () async -> Void = {
            reloadCallCount += 1
        }

        let workflow = FluelEntryMutationWorkflow(
            context: context,
            surface: "test",
            logger: logProbe.logger(category: "EntryMutation"),
            reloadTimelines: reloadTimelines
        )

        let result = await workflow.create(
            input: .init(
                title: "Future home",
                startPrecision: .year,
                startYear: 4_000
            )
        )

        let entries = try context.fetch(FetchDescriptor<Entry>())

        #expect(entries.isEmpty)
        switch result {
        case let .failure(failure):
            #expect(failure.phase == .primaryMutation)
            #expect(failure.message.isEmpty == false)
        default:
            Issue.record("Expected primary mutation failure.")
        }
        #expect(reloadCallCount == 0)

        let events = await recordedEvents(
            from: logProbe
        )
        let failureEvent = try #require(events.first { event in
            event.message == "Entry mutation failed"
        })

        #expect(failureEvent.metadata["phase"] == "primaryMutation")
        #expect(failureEvent.metadata["result"] == "failure")
        #expect(failureEvent.metadata["operation"] == "createEntry")
    }

    @Test
    func create_returns_preflight_failure_when_task_is_cancelled() async throws {
        let context = try makeTestContext()
        let logProbe = FluelLogProbe()
        let workflow = FluelEntryMutationWorkflow(
            context: context,
            surface: "test",
            logger: logProbe.logger(category: "EntryMutation")
        )

        let task = Task {
            await workflow.create(
                input: .init(
                    title: "Wallet",
                    startPrecision: .year,
                    startYear: 2_020
                )
            )
        }

        task.cancel()
        let result = await task.value
        let entries = try context.fetch(FetchDescriptor<Entry>())

        #expect(entries.isEmpty)
        switch result {
        case let .failure(failure):
            #expect(failure.phase == .preflight)
            #expect(failure.message == "The mutation was cancelled.")
        default:
            Issue.record("Expected preflight failure.")
        }
    }

    @Test
    func create_returns_degraded_success_when_follow_up_fails() async throws {
        enum FollowUpError: LocalizedError {
            case failed

            var errorDescription: String? {
                "Widget timelines could not be refreshed."
            }
        }

        let context = try makeTestContext()
        let logProbe = FluelLogProbe()
        let reloadTimelines: @MainActor () async throws -> Void = {
            throw FollowUpError.failed
        }

        let workflow = FluelEntryMutationWorkflow(
            context: context,
            surface: "test",
            logger: logProbe.logger(category: "EntryMutation"),
            reloadTimelines: reloadTimelines
        )

        let result = await workflow.create(
            input: .init(
                title: "Bag",
                startPrecision: .month,
                startYear: 2_025,
                startMonth: 3
            )
        )

        let entries = try context.fetch(FetchDescriptor<Entry>())

        #expect(entries.count == 1)
        #expect(
            result == .degradedSuccess(
                message: "Widget timelines could not be refreshed."
            )
        )

        let events = await recordedEvents(
            from: logProbe
        )
        let failureEvent = try #require(events.first { event in
            event.message == "Entry mutation failed"
                && event.metadata["phase"] == "postCommitFollowUp"
        })

        #expect(failureEvent.metadata["result"] == "degradedSuccess")
        #expect(failureEvent.metadata["followUp"] == "reloadWidgetTimelines")
    }

    @Test
    func create_returns_degraded_success_when_follow_up_is_cancelled() async throws {
        let context = try makeTestContext()
        let logProbe = FluelLogProbe()
        let reloadTimelines: @MainActor () async throws -> Void = {
            throw CancellationError()
        }

        let workflow = FluelEntryMutationWorkflow(
            context: context,
            surface: "test",
            logger: logProbe.logger(category: "EntryMutation"),
            reloadTimelines: reloadTimelines
        )

        let result = await workflow.create(
            input: .init(
                title: "Bag",
                startPrecision: .month,
                startYear: 2_025,
                startMonth: 3
            )
        )

        let entries = try context.fetch(FetchDescriptor<Entry>())

        #expect(entries.count == 1)
        #expect(
            result == .degradedSuccess(
                message: "Widget timelines could not be refreshed."
            )
        )
    }
}

private func makeTestContext() throws -> ModelContext {
    .init(try ModelContainerFactory.inMemory())
}

private extension FluelEntryMutationWorkflowTests {
    func recordedEvents(
        from probe: FluelLogProbe
    ) async -> [FluelRecordedLogEvent] {
        await Task.yield()
        await Task.yield()
        return await probe.events()
    }
}
