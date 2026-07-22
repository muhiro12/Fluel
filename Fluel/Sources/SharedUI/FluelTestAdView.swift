//
//  FluelTestAdView.swift
//  Fluel
//
//  Created by Codex on 2026/07/22.
//

import GoogleMobileAdsWrapper
import SwiftUI

struct FluelTestAdView: View {
    private enum Configuration {
        static let testNativeAdUnitID = "ca-app-pub-3940256099942544/3986624511"
        static let nativeAdSizeID = "Small"
    }

    @State private var controller = GoogleMobileAdsController(
        adUnitID: Configuration.testNativeAdUnitID
    )

    var body: some View {
        controller.buildNativeAd(Configuration.nativeAdSizeID)
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Sponsored")
            .task {
                controller.start()
            }
    }
}

#Preview {
    FluelTestAdView()
}
