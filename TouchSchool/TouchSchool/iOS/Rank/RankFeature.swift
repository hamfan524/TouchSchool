//
//  RankFeature.swift
//  TouchSchool
//
//  Created by 최동호 on 4/6/24.
//

import ComposableArchitecture

import SwiftUI

@Reducer
struct RankFeature {
    @ObservableState
    struct State: Equatable {
        var mySchool: SchoolInfo
        var mySchoolRank: Int
        var schoolInfo: IdentifiedArrayOf<SchoolInfo>
        var openAdView: Bool = true
    }
    
    enum Action {
        case closeAd
        case tabBackButton
    }
    
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .closeAd:
                state.openAdView = false
                return .none
            case .tabBackButton:
                return .run { _ in
                    await self.dismiss()
                }
            }
        }
    }
}
