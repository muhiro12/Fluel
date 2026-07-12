import Foundation

/// Stable identity for a built-in starter preset.
public enum EntryStarterPreset: String, CaseIterable, Identifiable, Sendable {
    case thisHome
    case wallet
    case bag
    case shoes
    case watch
    case plant
    case notebook

    /// Stable identifier used by persisted starter preset records.
    public var id: UUID {
        switch self {
        case .thisHome:
            Self.makeID("11111111-1111-1111-1111-111111111111")
        case .wallet:
            Self.makeID("22222222-2222-2222-2222-222222222222")
        case .bag:
            Self.makeID("33333333-3333-3333-3333-333333333333")
        case .shoes:
            Self.makeID("44444444-4444-4444-4444-444444444444")
        case .watch:
            Self.makeID("55555555-5555-5555-5555-555555555555")
        case .plant:
            Self.makeID("66666666-6666-6666-6666-666666666666")
        case .notebook:
            Self.makeID("77777777-7777-7777-7777-777777777777")
        }
    }

    var canonicalTitle: String {
        switch self {
        case .thisHome:
            "This home"
        case .wallet:
            "Wallet"
        case .bag:
            "Bag"
        case .shoes:
            "Shoes"
        case .watch:
            "Watch"
        case .plant:
            "Plant"
        case .notebook:
            "Notebook"
        }
    }

    var displayTitle: String {
        EntryLocalization.string("preset.starter.\(rawValue)")
    }

    init?(id: UUID) {
        guard let starterPreset = Self.allCases.first(where: { starterPreset in
            starterPreset.id == id
        }) else {
            return nil
        }

        self = starterPreset
    }

    private static func makeID(_ value: String) -> UUID {
        guard let resolvedID = UUID(uuidString: value) else {
            preconditionFailure("Starter preset identifiers must be valid UUIDs.")
        }

        return resolvedID
    }
}
