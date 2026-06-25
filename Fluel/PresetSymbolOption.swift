//
//  PresetSymbolOption.swift
//  Fluel
//
//  Created by Codex on 2026/06/26.
//

enum PresetSymbolOption: String, CaseIterable, Identifiable {
    case bookmark
    case home
    case wallet
    case bag
    case shoes
    case watch
    case plant
    case notebook
    case key
    case car

    var id: Self {
        self
    }

    var label: String {
        switch self {
        case .bookmark:
            "Bookmark"
        case .home:
            "Home"
        case .wallet:
            "Wallet"
        case .bag:
            "Bag"
        case .shoes:
            "Shoes"
        case .watch:
            "Watch"
        case .plant:
            "Plant"
        case .notebook:
            "Notebook"
        case .key:
            "Key"
        case .car:
            "Car"
        }
    }

    var symbolName: String {
        switch self {
        case .bookmark:
            "bookmark"
        case .home:
            "house"
        case .wallet:
            "wallet.pass"
        case .bag:
            "bag"
        case .shoes:
            "shoeprints.fill"
        case .watch:
            "applewatch"
        case .plant:
            "leaf"
        case .notebook:
            "book.closed"
        case .key:
            "key"
        case .car:
            "car"
        }
    }

    static func option(for symbolName: String) -> Self {
        allCases.first { option in
            option.symbolName == symbolName
        } ?? .bookmark
    }
}
