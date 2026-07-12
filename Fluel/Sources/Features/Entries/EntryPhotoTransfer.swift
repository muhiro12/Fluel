//
//  EntryPhotoTransfer.swift
//  Fluel
//
//  Created by Codex on 2026/07/13.
//

import CoreTransferable
import Foundation
import UniformTypeIdentifiers

struct EntryPhotoTransfer: Transferable, Sendable {
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .image) { receivedFile in
            try Task.checkCancellation()

            return try Self(data: EntryPhotoProcessor.process(receivedFile.file))
        }
    }

    let data: Data
}
