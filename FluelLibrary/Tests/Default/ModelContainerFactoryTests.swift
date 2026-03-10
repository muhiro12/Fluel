@testable import FluelLibrary
import Foundation
import SwiftData
import Testing

@MainActor
struct ModelContainerFactoryTests {
    @Test
    func inMemory_initializes_model_container() throws {
        let container = try ModelContainerFactory.inMemory()
        let context = container.mainContext

        _ = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Wallet",
                precision: .day,
                year: 2_024,
                month: 3,
                day: 8
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: .init(identifier: .gregorian)
        )

        #expect(try context.fetchCount(FetchDescriptor<Entry>()) == 1)
    }

    @Test
    func shared_initializes_model_container_with_custom_url() throws {
        let fileManager: FileManager = .default
        let directory = fileManager.temporaryDirectory.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        let storeURL = directory.appendingPathComponent(Database.fileName)

        defer {
            try? fileManager.removeItem(at: directory)
        }

        let container = try ModelContainerFactory.shared(
            storeURL: storeURL,
            fileManager: fileManager
        )

        _ = container.mainContext

        #expect(fileManager.fileExists(atPath: directory.path))
    }
}
