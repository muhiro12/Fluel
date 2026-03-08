import FluelLibrary
import Foundation

enum EntryPresetSource: String, Codable, Sendable {
    case builtIn
    case custom
}

struct EntryPresetDefinition: Codable, Equatable, Sendable {
    var title: String
    var symbolName: String
    var startPrecision: EntryDatePrecision
    var relativeValue: Int
    var note: String

    init(
        title: String,
        symbolName: String,
        startPrecision: EntryDatePrecision,
        relativeValue: Int,
        note: String = String()
    ) {
        self.title = title
        self.symbolName = symbolName
        self.startPrecision = startPrecision
        self.relativeValue = max(0, relativeValue)
        self.note = note
    }

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var normalizedNote: String? {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return nil
        }

        return trimmed
    }
}

struct EntryPresetCatalogItem: Identifiable, Equatable, Sendable {
    var id: String
    var definition: EntryPresetDefinition
}

struct EntryCustomPresetRecord: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var definition: EntryPresetDefinition
    var createdAt: Date
    var updatedAt: Date
}

struct EntryPresetState: Codable, Equatable, Sendable {
    var isPinned: Bool
    var lastUsedAt: Date?

    init(
        isPinned: Bool = false,
        lastUsedAt: Date? = nil
    ) {
        self.isPinned = isPinned
        self.lastUsedAt = lastUsedAt
    }
}

struct EntryPreset: Identifiable, Equatable, Sendable {
    var id: String
    var source: EntryPresetSource
    var definition: EntryPresetDefinition
    var isPinned: Bool
    var lastUsedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?

    var title: String {
        definition.title
    }

    var symbolName: String {
        definition.symbolName
    }

    var startPrecision: EntryDatePrecision {
        definition.startPrecision
    }

    var relativeValue: Int {
        definition.relativeValue
    }

    var note: String? {
        definition.normalizedNote
    }

    var isEditable: Bool {
        source == .custom
    }
}

enum EntryPresetCatalog {
    static var builtInItems: [EntryPresetCatalogItem] {
        []
    }
}
