//
//  FluelStartupFailureView.swift
//  Fluel
//
//  Created by Codex on 2026/06/27.
//

import SwiftUI

struct FluelStartupFailureView: View {
    var body: some View {
        ContentUnavailableView {
            Label("Fluel could not start", systemImage: "exclamationmark.triangle")
        } description: {
            Text("The app could not prepare its entry storage. Please try again later.")
        }
    }
}
