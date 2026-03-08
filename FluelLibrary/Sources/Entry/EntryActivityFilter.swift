import Foundation

/// Visible filter options for narrowing the activity timeline by kind.
public enum EntryActivityFilterMode: String, CaseIterable, Sendable {
    case all
    case added
    case updated
    case archived
}

/// Filters activity snapshots without changing their existing order.
public enum EntryActivityFilter {
    public static func filter(
        _ activity: [EntryActivitySnapshot],
        mode: EntryActivityFilterMode
    ) -> [EntryActivitySnapshot] {
        switch mode {
        case .all:
            return activity
        case .added:
            return activity.filter { $0.kind == .added }
        case .updated:
            return activity.filter { $0.kind == .updated }
        case .archived:
            return activity.filter { $0.kind == .archived }
        }
    }
}
