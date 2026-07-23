//
//  DashboardSupportingFeatureArtwork.swift
//  Fluel
//
//  Created by Codex on 2026/07/23.
//

import MHUI
import SwiftUI

struct DashboardSupportingFeatureArtwork: View {
    let systemImage: String

    var body: some View {
        ZStack {
            Rectangle()
                .mhForegroundStyle(.surfaceMuted)

            Image(systemName: systemImage)
                .font(.title2)
                .mhForegroundStyle(.accent)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}
