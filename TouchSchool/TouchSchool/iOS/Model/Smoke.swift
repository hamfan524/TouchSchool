//
//  Sparkle.swift
//  TouchSchool
//
//  Created by 최동호 on 11/16/23.
//

import SwiftUI

struct Smoke: Hashable, Identifiable {
    let id = UUID()
    var location: CGPoint
    var showEffect: Bool
    var angle: Double
    var opacity: Double
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
