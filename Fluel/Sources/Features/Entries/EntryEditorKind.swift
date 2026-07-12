//
//  EntryEditorKind.swift
//  Fluel
//
//  Created by Codex on 2026/07/13.
//

import SwiftUI

enum EntryEditorKind {
    case create
    case edit

    var navigationTitle: Text {
        switch self {
        case .create:
            Text("New Entry")
        case .edit:
            Text("Edit Entry")
        }
    }

    var discardConfirmationTitle: Text {
        switch self {
        case .create:
            Text("Discard this entry?")
        case .edit:
            Text("Discard changes?")
        }
    }

    var discardButtonTitle: Text {
        switch self {
        case .create:
            Text("Discard Entry")
        case .edit:
            Text("Discard Changes")
        }
    }

    var saveErrorTitle: Text {
        switch self {
        case .create:
            Text("Entry could not be saved")
        case .edit:
            Text("Entry could not be updated")
        }
    }
}
