//
//  Item.swift
//  Fluel
//
//  Created by Hiromu Nakano on 2026/03/07.
//

import Foundation
import SwiftData

@Model
final class Item {
    var name: String = ""
    var startDate: Date = Date.now

    init(name: String, startDate: Date) {
        self.name = name
        self.startDate = startDate
    }
}
