//
//  EntryPhotoDetailSection.swift
//  Fluel
//
//  Created by Codex on 2026/07/13.
//

import MHUI
import SwiftUI

struct EntryPhotoDetailSection: View {
    private enum Layout {
        static let maximumImageHeight = 360.0
    }

    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let photoData: Data?

    var body: some View {
        if let photoData {
            EntryPhotoImage(photoData: photoData)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: Layout.maximumImageHeight)
                .clipShape(.rect(cornerRadius: designMetrics.cornerRadius.surface))
                .mhSection("Photo")
        }
    }
}
