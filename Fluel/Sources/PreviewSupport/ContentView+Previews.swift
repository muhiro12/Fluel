//
//  ContentView+Previews.swift
//  Fluel
//
//  Created by Codex on 2026/07/17.
//

import SwiftUI

#Preview("Active entries - empty") {
    FluelPreviewContainer(.empty) {
        ContentView()
    }
}

#Preview("Active entries - typical") {
    FluelPreviewContainer {
        ContentView()
    }
}

#Preview("Active entries - dense, large type") {
    FluelPreviewContainer(.dense) {
        ContentView()
    }
    .dynamicTypeSize(.accessibility2)
}

#Preview("Active entries - dark") {
    FluelPreviewContainer {
        ContentView()
    }
    .preferredColorScheme(.dark)
}
