//
//  EntryPhotoDetailSection.swift
//  Fluel
//
//  Created by Codex on 2026/07/13.
//

import SwiftUI

struct EntryPhotoDetailSection: View {
    private enum Layout {
        static let maximumImageHeight = 360.0
        static let cornerRadius = 12.0
    }

    let photoData: Data?

    var body: some View {
        if let photoData {
            Section("Photo") {
                EntryPhotoImage(photoData: photoData)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: Layout.maximumImageHeight)
                    .clipShape(.rect(cornerRadius: Layout.cornerRadius))
            }
        }
    }
}
