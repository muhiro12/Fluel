//
//  EntryPhotoImage.swift
//  Fluel
//
//  Created by Codex on 2026/07/13.
//

import MHUI
import SwiftUI
import UIKit

struct EntryPhotoImage: View {
    private enum Layout {
        static let minimumUnavailableHeight = 120.0
    }

    private enum LoadState {
        case loading
        case loaded(UIImage)
        case unavailable
    }

    @State private var loadState = LoadState.loading

    let photoData: Data

    var body: some View {
        Group {
            switch loadState {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel("Preparing Photo")
            case .loaded(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .accessibilityLabel("Entry photo")
            case .unavailable:
                Label("Photo unavailable", systemImage: "photo.badge.exclamationmark")
                    .mhForegroundStyle(.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: Layout.minimumUnavailableHeight)
            }
        }
        .task(id: photoData) {
            loadState = .loading
            loadState = UIImage(data: photoData).map(LoadState.loaded) ?? .unavailable
        }
    }
}
