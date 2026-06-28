//
//  ActiveEntrySheet.swift
//  Fluel
//
//  Created by Codex on 2026/06/25.
//

import FluelLibrary
import Foundation

struct ActiveEntrySheet: Identifiable {
    let id = UUID()
    let draft: EntryDraft
}
