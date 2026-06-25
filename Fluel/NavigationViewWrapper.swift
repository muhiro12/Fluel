//
//  NavigationViewWrapper.swift
//  Fluel
//
//  Created by Hiromu Nakano on 2026/06/25.
//

import SwiftUI

struct NavigationViewWrapper<Content: View>: View {
    let content: () -> Content

    var body: some View {
#if os(macOS)
        NavigationSplitView {
            content()
        } detail: {
            Text("Select an item")
        }
#else
        content()
#endif
    }
}
