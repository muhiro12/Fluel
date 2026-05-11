import Foundation

/// Shared App Group identifiers and resolved container locations.
public enum AppGroup {
    /// App Group identifier shared by the app and widget extension.
    public static let id = "group.com.muhiro12.Fluel"

    /// Returns the root container URL for the shared App Group.
    public static func containerURL(
        fileManager: FileManager = .default
    ) -> URL {
        guard let url = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: id
        ) else {
            preconditionFailure("Failed to resolve App Group container URL.")
        }

        return url
    }
}
