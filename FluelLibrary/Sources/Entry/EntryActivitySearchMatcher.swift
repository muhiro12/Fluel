import Foundation

/// Matches activity timeline rows against a lightweight search query.
public enum EntryActivitySearchMatcher {
    public static func filter(
        _ activity: [EntryActivitySnapshot],
        matching query: String
    ) -> [EntryActivitySnapshot] {
        let normalizedQuery = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard normalizedQuery.isEmpty == false else {
            return activity
        }

        let lowercasedQuery = normalizedQuery.lowercased()
        return activity.filter { snapshot in
            searchableText(for: snapshot).contains(lowercasedQuery)
        }
    }
}

private extension EntryActivitySearchMatcher {
    static func searchableText(
        for snapshot: EntryActivitySnapshot
    ) -> String {
        (
            [snapshot.title, snapshot.kind.rawValue]
            + kindKeywords(for: snapshot.kind)
        )
        .joined(separator: " ")
        .lowercased()
    }

    static func kindKeywords(
        for kind: EntryActivityKind
    ) -> [String] {
        switch kind {
        case .added:
            return ["added", "add", "追加"]
        case .updated:
            return ["updated", "update", "更新"]
        case .archived:
            return ["archived", "archive", "保管"]
        }
    }
}
