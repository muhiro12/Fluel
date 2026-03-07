import Foundation

/// Shared App Group identifiers and resolved container locations.
public enum AppGroup {
    /// App Group identifier shared by the app and widget extension.
    public static let id = "group.com.muhiro12.Fluel"

    /// Returns the shared container URL, or a simulator-safe fallback when unavailable.
    public static func containerURL(
        fileManager: FileManager = .default
    ) -> URL {
        if let url = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: id
        ) {
            return url
        }

        let fallbackDirectory = (fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? URL.documentsDirectory)
        .appendingPathComponent("FluelShared", isDirectory: true)

        do {
            try fileManager.createDirectory(
                at: fallbackDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            assertionFailure("Failed to create fallback App Group directory: \(error)")
        }

        return fallbackDirectory
    }
}
