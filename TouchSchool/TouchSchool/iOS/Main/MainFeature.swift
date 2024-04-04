//
//  MainFeature.swift
//  TouchSchool
//
//  Created by 최동호 on 4/4/24.
//

import ComposableArchitecture

import Foundation

@Reducer
struct MainFeature {
    @ObservableState
    struct State: Equatable {
        var schools: IdentifiedArrayOf<School> = []
        var isDownloading: Bool = true
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case dataResponse(IdentifiedArrayOf<School>)
        case fetchData
        case openMain
        case openGameView
        case openSearchView
        case openRankView
        case path(StackAction<Path.State, Path.Action>)
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
            case .openGameView:
                state.path.append(.gameScene(GameFeature.State()))
                return .none
            case .openRankView:
                state.path.append(.rankScene(RankFeature.State()))
                return .none
            case .openSearchView:
                state.path.append(.searchScene(SearchFeature.State(
                    schools: state.schools
                )))
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
}

extension MainFeature {
    @Reducer
    struct Path {
        @ObservableState
        enum State: Equatable {
            case gameScene(GameFeature.State)
            case rankScene(RankFeature.State)
            case searchScene(SearchFeature.State)

        }
        
        enum Action {
            case gameScene(GameFeature.Action)
            case rankScene(RankFeature.Action)
            case searchScene(SearchFeature.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: \.gameScene, action: \.gameScene) {
                GameFeature()
            }
            Scope(state: \.rankScene, action: \.rankScene) {
                RankFeature()
            }
            Scope(state: \.searchScene, action: \.searchScene) {
                SearchFeature()
            }
        }
    }
}
