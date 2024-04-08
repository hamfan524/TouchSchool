//
//  SmokeEffectView.swift
//  TouchSchool
//
//  Created by 최동호 on 4/6/24.
//

import SwiftUI

struct SmokeEffectView: View {
    var smoke: Smoke
    
    var body: some View {
        Image("smoke")
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
    }
}
