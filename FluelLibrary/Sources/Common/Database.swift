import Foundation

/// Shared database file locations used by the app and widget extension.
public enum Database {
    /// Shared SQLite filename.
    public static let fileName = "Fluel.sqlite"

    /// Current SQLite store URL inside the shared App Group container.
    public static func url(
        fileManager: FileManager = .default
    ) -> URL {
        AppGroup.containerURL(fileManager: fileManager)
            .appendingPathComponent(fileName)
    }
}
