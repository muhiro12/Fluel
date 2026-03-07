import Foundation
import SwiftData

/// Factory helpers to create shared or in-memory model containers.
public enum ModelContainerFactory {
    /// Creates a `ModelContainer` persisted at the shared database location.
    public static func shared(
        fileManager: FileManager = .default
    ) throws -> ModelContainer {
        try shared(
            storeURL: Database.url(fileManager: fileManager),
            fileManager: fileManager
        )
    }

    /// Creates a `ModelContainer` persisted at `storeURL`.
    public static func shared(
        storeURL: URL,
        fileManager: FileManager = .default
    ) throws -> ModelContainer {
        try fileManager.createDirectory(
            at: storeURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )

        return try .init(
            for: Entry.self,
            configurations: .init(
                url: storeURL
            )
        )
    }

    /// Creates an in-memory `ModelContainer` for previews and tests.
    public static func inMemory() throws -> ModelContainer {
        try .init(
            for: Entry.self,
            configurations: .init(
                isStoredInMemoryOnly: true
            )
        )
    }
}
