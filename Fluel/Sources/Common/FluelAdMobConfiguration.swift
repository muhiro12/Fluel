//
//  FluelAdMobConfiguration.swift
//  Fluel
//
//  Created by Hiromu Nakano on 2026/03/08.
//

enum FluelAdMobConfiguration {
    // Matches Incomes' debug native ad unit so local startup can exercise the same path.
    nonisolated static let nativeAdUnitIDDev = "ca-app-pub-3940256099942544/3986624511"

    nonisolated static var nativeAdUnitID: String? {
        #if DEBUG
        nativeAdUnitIDDev
        #else
        nil
        #endif
    }
}
