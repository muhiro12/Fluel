//
//  EntryEditorRoute.swift
//  Fluel
//
//  Created by Codex on 2026/07/13.
//

import FluelLibrary
import Foundation

struct EntryEditorRoute: Identifiable {
    let id = UUID()
    let entry: Entry?
    let draft: EntryDraft
    let photoData: Data?
}
