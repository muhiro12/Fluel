import FluelLibrary
import Foundation
import MHPlatform
import Observation

// swiftlint:disable file_length
@Observable
@MainActor
final class EntryPresetStore {
    private static let previewNotebookRelativeValue = 4

    private(set) var customRecords: [EntryCustomPresetRecord]
    private(set) var presetStates: [String: EntryPresetState]
    private(set) var defaultPresetID: String?
    private(set) var usesDefaultPreset: Bool

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let encoder = JSONEncoder()
    @ObservationIgnored private let decoder = JSONDecoder()
    @ObservationIgnored private let logger: MHLogger?

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

    var pinnedPresets: [EntryPreset] {
        allPresets
            .filter(\.isPinned)
            .sorted(by: isHigherPriorityPreset(_:_:))
    }

    var recentPresets: [EntryPreset] {
        allPresets
            .filter { preset in
                preset.isPinned == false && preset.lastUsedAt != nil
            }
            .sorted(by: isHigherPriorityPreset(_:_:))
    }

    var defaultPreset: EntryPreset? {
        guard let defaultPresetID else {
            return nil
        }

        return preset(id: defaultPresetID)
    }

    var defaultCreatePresetID: String? {
        guard usesDefaultPreset else {
            return nil
        }

        return defaultPreset?.id
    }

    init(
        defaults: UserDefaults = EntryPresetPreferences.store,
        logger: MHLogger? = nil
    ) {
        self.defaults = defaults
        self.logger = logger
        customRecords = Self.loadRecords(
            from: defaults,
            decoder: decoder,
            logger: logger
        )
        presetStates = Self.loadStates(
            from: defaults,
            decoder: decoder,
            logger: logger
        )
        defaultPresetID = defaults.string(
            forKey: EntryPresetPreferences.defaultPresetID
        )
        usesDefaultPreset = defaults.object(
            forKey: EntryPresetPreferences.usesDefaultPreset
        ) as? Bool ?? false
        sanitizeDefaultPreset()
    }

    func preset(
        id: String
    ) -> EntryPreset? {
        allPresets.first { preset in
            preset.id == id
        }
    }

    func saveCustomPreset(
        definition: EntryPresetDefinition,
        id: String? = nil,
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
        logger?.notice(
            "Preset stored",
            metadata: [
                "action": id == nil ? "create" : "update",
                "presetID": recordID,
                "hasNote": String(hasContent(in: definition.note)),
                "startPrecision": definition.startPrecision.rawValue
            ]
        )
    }

    func deleteCustomPreset(
        id: String
    ) {
        customRecords.removeAll { record in
            record.id == id
        }
        presetStates[id] = nil

        if defaultPresetID == id {
            defaultPresetID = nil
            usesDefaultPreset = false
            persistDefaultPresetID()
            persistUsesDefaultPreset()
        }

        persistRecords()
        persistStates()
        logger?.notice(
            "Preset deleted",
            metadata: [
                "presetID": id
            ]
        )
    }

    func setDefaultPreset(
        id: String?
    ) {
        defaultPresetID = id

        if id == nil {
            usesDefaultPreset = false
            persistUsesDefaultPreset()
        }

        persistDefaultPresetID()
        logger?.notice(
            "Default preset updated",
            metadata: [
                "presetID": id ?? "none",
                "usesDefaultPreset": String(usesDefaultPreset)
            ]
        )
    }

    func setUsesDefaultPreset(
        _ usesDefaultPreset: Bool
    ) {
        self.usesDefaultPreset = usesDefaultPreset && defaultPreset != nil
        persistUsesDefaultPreset()
        logger?.notice(
            "Default preset usage updated",
            metadata: [
                "isEnabled": String(self.usesDefaultPreset)
            ]
        )
    }

    func setPinned(
        _ isPinned: Bool,
        for id: String
    ) {
        var state = presetStates[id] ?? .init()
        state.isPinned = isPinned
        presetStates[id] = state
        persistStates()
        logger?.notice(
            "Preset pin state updated",
            metadata: [
                "presetID": id,
                "isPinned": String(isPinned)
            ]
        )
    }

    func markUsed(
        _ id: String,
        at now: Date = .now
    ) {
        var state = presetStates[id] ?? .init()
        state.lastUsedAt = now
        presetStates[id] = state
        persistStates()
        logger?.notice(
            "Preset marked used",
            metadata: [
                "presetID": id
            ]
        )
    }
}

extension EntryPresetStore {
    static func preview() -> EntryPresetStore {
        let defaults = UserDefaults(
            suiteName: "EntryPresetStore.preview.\(UUID().uuidString)"
        ) ?? .standard
        let store = EntryPresetStore(
            defaults: defaults
        )

        store.saveCustomPreset(
            definition: .init(
                title: FluelCopy.starterNotebookTitle(),
                symbolName: "notebook",
                startPrecision: .month,
                relativeValue: previewNotebookRelativeValue,
                note: FluelCopy.starterNotebookNote()
            ),
            at: .distantPast
        )
        store.setPinned(true, for: "starter-home")
        store.markUsed("starter-home")
        store.markUsed("starter-wallet")
        store.markUsed("starter-plant")
        store.setDefaultPreset(id: "starter-home")
        store.setUsesDefaultPreset(true)
        return store
    }
}

extension EntryPresetStore {
    func suggestedPresets(
        limit: Int
    ) -> [EntryPreset] {
        let prioritizedGroups = [
            pinnedPresets,
            recentPresets,
            builtInPresets,
            customPresets
        ]
        var seenIDs = Set<String>()
        var presets = [EntryPreset]()

        for group in prioritizedGroups {
            for preset in group where seenIDs.insert(preset.id).inserted {
                presets.append(preset)

                if presets.count >= limit {
                    return presets
                }
            }
        }

        return presets
    }

    func resolvedInput(
        for id: String,
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> EntryFormInput? {
        guard let preset = preset(id: id) else {
            return nil
        }

        return resolvedInput(
            for: preset,
            referenceDate: referenceDate,
            calendar: calendar
        )
    }

    func resolvedInput(
        for preset: EntryPreset,
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> EntryFormInput {
        preset.definition.resolvedInput(
            referenceDate: referenceDate,
            calendar: calendar
        )
    }
}

private extension EntryPresetStore {
    func makePreset(
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

    func isHigherPriorityPreset(
        _ lhs: EntryPreset,
        _ rhs: EntryPreset
    ) -> Bool {
        if lhs.lastUsedAt != rhs.lastUsedAt {
            return (lhs.lastUsedAt ?? .distantPast)
                > (rhs.lastUsedAt ?? .distantPast)
        }

        if lhs.updatedAt != rhs.updatedAt {
            return (lhs.updatedAt ?? .distantPast)
                > (rhs.updatedAt ?? .distantPast)
        }

        if lhs.createdAt != rhs.createdAt {
            return (lhs.createdAt ?? .distantPast)
                > (rhs.createdAt ?? .distantPast)
        }

        return lhs.title.localizedCaseInsensitiveCompare(
            rhs.title
        ) == .orderedAscending
    }

    func persistRecords() {
        do {
            let data = try encoder.encode(customRecords)
            defaults.set(
                data,
                forKey: EntryPresetPreferences.customPresetRecords
            )
        } catch {
            logger?.error(
                "Preset record persistence failed",
                metadata: [
                    "preference": EntryPresetPreferences.customPresetRecords,
                    "error": error.localizedDescription
                ]
            )
        }
    }

    func persistStates() {
        do {
            let data = try encoder.encode(presetStates)
            defaults.set(
                data,
                forKey: EntryPresetPreferences.presetStates
            )
        } catch {
            logger?.error(
                "Preset state persistence failed",
                metadata: [
                    "preference": EntryPresetPreferences.presetStates,
                    "error": error.localizedDescription
                ]
            )
        }
    }

    func persistDefaultPresetID() {
        defaults.set(
            defaultPresetID,
            forKey: EntryPresetPreferences.defaultPresetID
        )
    }

    func persistUsesDefaultPreset() {
        defaults.set(
            usesDefaultPreset,
            forKey: EntryPresetPreferences.usesDefaultPreset
        )
    }

    func sanitizeDefaultPreset() {
        guard let defaultPresetID else {
            if usesDefaultPreset {
                usesDefaultPreset = false
                persistUsesDefaultPreset()
                logger?.warning(
                    "Default preset usage repaired",
                    metadata: [
                        "reason": "missingDefaultPresetID"
                    ]
                )
            }
            return
        }

        guard preset(id: defaultPresetID) != nil else {
            self.defaultPresetID = nil
            usesDefaultPreset = false
            persistDefaultPresetID()
            persistUsesDefaultPreset()
            logger?.warning(
                "Default preset selection repaired",
                metadata: [
                    "reason": "missingPresetRecord"
                ]
            )
            return
        }
    }

    func hasContent(
        in note: String
    ) -> Bool {
        note.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty == false
    }
}

private extension EntryPresetStore {
    static func loadRecords(
        from defaults: UserDefaults,
        decoder: JSONDecoder,
        logger: MHLogger?
    ) -> [EntryCustomPresetRecord] {
        guard let data = defaults.data(
            forKey: EntryPresetPreferences.customPresetRecords
        ) else {
            return []
        }

        do {
            return try decoder.decode(
                [EntryCustomPresetRecord].self,
                from: data
            )
        } catch {
            logger?.warning(
                "Preset record decode failed",
                metadata: [
                    "preference": EntryPresetPreferences.customPresetRecords,
                    "error": error.localizedDescription
                ]
            )
            return []
        }
    }

    static func loadStates(
        from defaults: UserDefaults,
        decoder: JSONDecoder,
        logger: MHLogger?
    ) -> [String: EntryPresetState] {
        guard let data = defaults.data(
            forKey: EntryPresetPreferences.presetStates
        ) else {
            return [:]
        }

        do {
            return try decoder.decode(
                [String: EntryPresetState].self,
                from: data
            )
        } catch {
            logger?.warning(
                "Preset state decode failed",
                metadata: [
                    "preference": EntryPresetPreferences.presetStates,
                    "error": error.localizedDescription
                ]
            )
            return [:]
        }
    }
}
// swiftlint:enable file_length
