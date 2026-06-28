//
//  Preset.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

import FluelLibrary
import Foundation
import SwiftData

@Model
final class Preset {
    private enum StartKind {
        static let today = "today"
        static let monthsAgo = "monthsAgo"
        static let yearsAgo = "yearsAgo"
    }

    private enum StartValue {
        static let empty = 0
    }

    var id = UUID()
    var title = ""
    var symbolName = "clock"
    var startKind = StartKind.today
    var startValue = StartValue.empty
    var startPrecision = StartPrecision.day
    var note: String?
    var origin = EntryPresetOrigin.custom
    var isPinned = false
    var isDefault = false
    var lastUsedAt: Date?
    var createdAt = Date()
    var updatedAt = Date()

    var isCustom: Bool {
        origin == .custom
    }

    private var start: EntryPresetStart {
        switch startKind {
        case StartKind.monthsAgo:
            .monthsAgo(startValue)
        case StartKind.yearsAgo:
            .yearsAgo(startValue)
        default:
            .today
        }
    }

    var snapshot: EntryPreset {
        .init(
            title: title,
            symbolName: symbolName,
            start: start,
            startPrecision: startPrecision,
            origin: origin,
            id: id,
            note: note,
            isPinned: isPinned,
            isDefault: isDefault,
            lastUsedAt: lastUsedAt
        )
    }

    init(
        preset: EntryPreset,
        createdAt: Date,
        updatedAt: Date
    ) {
        id = preset.id
        title = preset.title
        symbolName = preset.symbolName
        startPrecision = preset.startPrecision
        note = preset.note
        origin = preset.origin
        isPinned = preset.isPinned
        isDefault = preset.isDefault
        lastUsedAt = preset.lastUsedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt

        let encodedStart = Self.encodedStart(preset.start)
        startKind = encodedStart.kind
        startValue = encodedStart.value
    }

    convenience init(preset: EntryPreset) {
        self.init(preset: preset, createdAt: .now, updatedAt: .now)
    }

    private static func encodedStart(_ start: EntryPresetStart) -> (kind: String, value: Int) {
        switch start {
        case .today:
            (StartKind.today, StartValue.empty)
        case .monthsAgo(let value):
            (StartKind.monthsAgo, value)
        case .yearsAgo(let value):
            (StartKind.yearsAgo, value)
        }
    }

    func apply(_ preset: EntryPreset) {
        title = preset.title
        symbolName = preset.symbolName
        startPrecision = preset.startPrecision
        note = preset.note
        origin = preset.origin
        isPinned = preset.isPinned
        isDefault = preset.isDefault
        lastUsedAt = preset.lastUsedAt
        updatedAt = .now

        let encodedStart = Self.encodedStart(preset.start)
        startKind = encodedStart.kind
        startValue = encodedStart.value
    }
}
