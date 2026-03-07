import Foundation

/// Shared text filtering helpers for entry collections.
public enum EntrySearchMatcher {
    public static func filter(
        _ entries: [Entry],
        matching query: String,
        locale: Locale = .autoupdatingCurrent
    ) -> [Entry] {
        let normalizedQuery = normalize(
            query,
            locale: locale
        )

        guard normalizedQuery.isEmpty == false else {
            return entries
        }

        return entries.filter { entry in
            matches(
                entry,
                normalizedQuery: normalizedQuery,
                locale: locale
            )
        }
    }
}

private extension EntrySearchMatcher {
    static func matches(
        _ entry: Entry,
        normalizedQuery: String,
        locale: Locale
    ) -> Bool {
        searchableFields(for: entry).contains { field in
            normalize(
                field,
                locale: locale
            ).contains(normalizedQuery)
        }
    }

    static func searchableFields(
        for entry: Entry
    ) -> [String] {
        [
            entry.title,
            entry.note
        ]
        .compactMap { $0 }
    }

    static func normalize(
        _ text: String,
        locale: Locale
    ) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(
                options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive],
                locale: locale
            )
    }
}
