//
//  ContentView.swift
//  TouchSchool
//
//  Created by 최동호 on 10/11/23.
//

import ComposableArchitecture

import SwiftUI

@Reducer
struct MainFeature {
    @ObservableState
    struct State: Equatable {
        var isDownloading: Bool = true
        var schools: IdentifiedArrayOf<School> = []
    }
    
    enum Action {
        case dataResponse(IdentifiedArrayOf<School>)
        case fetchData
        case openMain
    }
    
    @Dependency(\.searchResult) var searchResult

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchData:
                return .run { send in
                    try await send(.dataResponse(self.searchResult.fetch([eSchoolUrl, mSchoolUrl, hSchoolUrl])))
                    await send(.openMain)
                }
            case let .dataResponse(schools):
                state.schools = schools
                return .run { send in
                    await send(.openMain)
                }
            case .openMain:
                state.isDownloading = false
                return .none
            }
        }
    }
}

struct ContentView: View {
    @Bindable var store: StoreOf<MainFeature>
    
    var body: some View {
        ZStack{
            if store.isDownloading {
                Image("blackboard_set")
                    .resizable()
                    .ignoresSafeArea()
                
                ProgressView("학교 정보 받아오는 중..", value: 0)
                    .foregroundColor(Color.white)
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .padding()
                    .onAppear {
                        store.send(.fetchData)
                    }
            } else {
                MainView(store: store)
            }
        }
    }
}

