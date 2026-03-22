@testable import Fluel
import FluelLibrary
import SwiftData
import Testing

@MainActor
struct FluelEntryMutationWorkflowTests {
    @Test
    func create_persists_entry_and_runs_success_followUp() async throws {
        let context = try makeTestContext()
        var successCallCount = 0
        var errorMessages = [String]()
        var reloadCallCount = 0

        let workflow = FluelEntryMutationWorkflow(
            context: context,
            onSuccess: {
                successCallCount += 1
            },
            onError: { message in
                errorMessages.append(message)
            },
            reloadTimelines: {
                reloadCallCount += 1
            }
        )

        await workflow.create(
            input: .init(
                title: "Wallet",
                startPrecision: .year,
                startYear: 2_020
            )
        )

        let entries = try context.fetch(FetchDescriptor<Entry>())

        #expect(entries.count == 1)
        #expect(entries.first?.title == "Wallet")
        #expect(successCallCount == 1)
        #expect(errorMessages.isEmpty)
        #expect(reloadCallCount == 1)
    }

    @Test
    func create_surfaces_validation_error_without_success_sideEffects() async throws {
        let context = try makeTestContext()
        var successCallCount = 0
        var errorMessages = [String]()
        var reloadCallCount = 0

        let workflow = FluelEntryMutationWorkflow(
            context: context,
            onSuccess: {
                successCallCount += 1
            },
            onError: { message in
                errorMessages.append(message)
            },
            reloadTimelines: {
                reloadCallCount += 1
            }
        )

        await workflow.create(
            input: .init(
                title: "Future home",
                startPrecision: .year,
                startYear: 4_000
            )
        )

        let entries = try context.fetch(FetchDescriptor<Entry>())

        #expect(entries.isEmpty)
        #expect(successCallCount == 0)
        #expect(errorMessages.count == 1)
        #expect(errorMessages.first?.isEmpty == false)
        #expect(reloadCallCount == 0)
    }
}

private func makeTestContext() throws -> ModelContext {
    .init(try ModelContainerFactory.inMemory())
}
