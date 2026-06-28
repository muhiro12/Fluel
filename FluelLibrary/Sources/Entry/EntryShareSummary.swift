import Foundation

/// Share-ready subject and text.
public struct EntryShareSummary: Equatable, Sendable {
    /// Suggested share subject.
    public let subject: String
    /// Plain-text share body.
    public let text: String

    /// Creates share-ready text.
    public init(
        subject: String,
        text: String
    ) {
        self.subject = subject
        self.text = text
    }
}
