import Combine
import Foundation

@MainActor
final class EntryPresetStore: ObservableObject {
    @Published private(set) var customRecords: [EntryCustomPresetRecord]
    @Published private(set) var presetStates: [String: EntryPresetState]

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        defaults: UserDefaults = EntryPresetPreferences.store
    ) {
        self.defaults = defaults
        customRecords = Self.loadRecords(
            from: defaults,
            decoder: decoder
        )
        presetStates = Self.loadStates(
            from: defaults,
            decoder: decoder
        )
    }

    var builtInPresets: [EntryPreset] {
        EntryPresetCatalog.builtInItems.map { item in
            makePreset(
                id: item.id,
                source: .builtIn,
                definition: item.definition
            )
        }
    }

    var customPresets: [EntryPreset] {
        customRecords
            .sorted { lhs, rhs in
                if lhs.updatedAt != rhs.updatedAt {
                    return lhs.updatedAt > rhs.updatedAt
                }

                return lhs.definition.title.localizedCaseInsensitiveCompare(
                    rhs.definition.title
                ) == .orderedAscending
            }
            .map { record in
                makePreset(
                    id: record.id,
                    source: .custom,
                    definition: record.definition,
                    createdAt: record.createdAt,
                    updatedAt: record.updatedAt
                )
            }
    }

    var allPresets: [EntryPreset] {
        builtInPresets + customPresets
    }

    func preset(
        id: String
    ) -> EntryPreset? {
        allPresets.first { preset in
            preset.id == id
        }
    }

    func saveCustomPreset(
        id: String? = nil,
        definition: EntryPresetDefinition,
        at now: Date = .now
    ) {
        guard definition.trimmedTitle.isEmpty == false else {
            return
        }

        let recordID = id ?? UUID().uuidString

        if let existingIndex = customRecords.firstIndex(where: { record in
            record.id == recordID
        }) {
            customRecords[existingIndex].definition = definition
            customRecords[existingIndex].updatedAt = now
        } else {
            customRecords.append(
                .init(
                    id: recordID,
                    definition: definition,
                    createdAt: now,
                    updatedAt: now
                )
            )
        }

        persistRecords()
    }

    func deleteCustomPreset(
        id: String
    ) {
        customRecords.removeAll { record in
            record.id == id
        }
        presetStates[id] = nil
        persistRecords()
        persistStates()
    }

    func setPinned(
        _ isPinned: Bool,
        for id: String
    ) {
        var state = presetStates[id] ?? .init()
        state.isPinned = isPinned
        presetStates[id] = state
        persistStates()
    }

    func markUsed(
        _ id: String,
        at now: Date = .now
    ) {
        var state = presetStates[id] ?? .init()
        state.lastUsedAt = now
        presetStates[id] = state
        persistStates()
    }

    private func makePreset(
        id: String,
        source: EntryPresetSource,
        definition: EntryPresetDefinition,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) -> EntryPreset {
        let state = presetStates[id] ?? .init()

        return .init(
            id: id,
            source: source,
            definition: definition,
            isPinned: state.isPinned,
            lastUsedAt: state.lastUsedAt,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    private func persistRecords() {
        guard let data = try? encoder.encode(customRecords) else {
            return
        }

        defaults.set(data, forKey: EntryPresetPreferences.customPresetRecords)
    }

    private func persistStates() {
        guard let data = try? encoder.encode(presetStates) else {
            return
        }

        defaults.set(data, forKey: EntryPresetPreferences.presetStates)
    }

    private static func loadRecords(
        from defaults: UserDefaults,
        decoder: JSONDecoder
    ) -> [EntryCustomPresetRecord] {
        guard let data = defaults.data(
            forKey: EntryPresetPreferences.customPresetRecords
        ),
        let records = try? decoder.decode(
            [EntryCustomPresetRecord].self,
            from: data
        ) else {
            return []
        }

        return records
    }

    private static func loadStates(
        from defaults: UserDefaults,
        decoder: JSONDecoder
    ) -> [String: EntryPresetState] {
        guard let data = defaults.data(
            forKey: EntryPresetPreferences.presetStates
        ),
        let states = try? decoder.decode(
            [String: EntryPresetState].self,
            from: data
        ) else {
            return [:]
        }

        return states
    }
}
