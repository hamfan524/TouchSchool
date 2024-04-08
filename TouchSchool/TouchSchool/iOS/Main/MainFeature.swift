//
//  MainFeature.swift
//  TouchSchool
//
//  Created by 최동호 on 4/4/24.
//

import ComposableArchitecture
import FirebaseFirestore

import Foundation

@Reducer
struct MainFeature {
    @ObservableState
    struct State: Equatable {
        var mySchool: SchoolInfo = .init(name: "", adres: "", seq: "", count: 0)
        var mySchoolRank: Int = 0
        var schools: IdentifiedArrayOf<School> = []
        var schoolInfo: IdentifiedArrayOf<SchoolInfo> = []
        var isDownloading: Bool = true
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case dataResponse(IdentifiedArrayOf<School>)
        case fetchData
        case fetchMySchoolData
        case openMain
        case openGameView
        case openSearchView
        case openRankView
        case path(StackAction<Path.State, Path.Action>)
        case rankDataResponse([SchoolInfo])
        case setMySchoolData(SchoolInfo)
    }
    
    @Dependency(\.searchResult) var searchResult
    @Dependency(\.firestoreAPI) var firestoreAPI

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .dataResponse(schools):
                state.schools = schools
                return .run { send in
                    await send(.openMain)
                }

            case .fetchData:
                return .run { send in
                    await send(.fetchMySchoolData)
                    for try await schools in try await firestoreAPI.fetchSchool() {
                        await send(.rankDataResponse(schools))
                    }
                }
            
            case .fetchMySchoolData:
                return .run { send in
                    for try await mySchool in try await firestoreAPI.fetchMySchoolData() {
                        await send(.setMySchoolData(mySchool))
                    }
                }
                
            case .openMain:
                state.isDownloading = false
                return .none
                
            case .openGameView:
                pathId = "game"
                state.path.append(.gameScene(GameFeature.State(
                    mySchool: state.mySchool,
                    mySchoolRank: state.mySchoolRank,
                    schoolInfo: state.schoolInfo
                )))
                return .none
                
            case .openRankView:
                pathId = "rank"
                state.path.append(.rankScene(RankFeature.State(
                    mySchool: state.mySchool,
                    mySchoolRank: state.mySchoolRank,
                    schoolInfo: state.schoolInfo
                )))
                return .none
                
            case .openSearchView:
                pathId = "search"
                state.path.append(.searchScene(SearchFeature.State(
                    schools: state.schools
                )))
                return .none
                
            case .path:
                return .none
                
            case let .rankDataResponse(schoolInfo):
                state.schoolInfo = IdentifiedArray(uniqueElements: schoolInfo)
                
                let myRank = schoolInfo.firstIndex(where: { $0.seq == seqValue }) ?? (schoolInfo.count - 1)
                state.mySchoolRank = myRank + 1
                
                if !state.path.isEmpty {
                    let key = state.path.ids.first!
                    
                    switch pathId {
                    case "game":
                        state.path[id: key] = .gameScene(GameFeature.State(
                            mySchool: state.mySchool,
                            mySchoolRank: state.mySchoolRank,
                            schoolInfo: state.schoolInfo
                        ))
                        
                    case "rank":
                        state.path[id: key] = .rankScene(RankFeature.State(
                            mySchool: state.mySchool,
                            mySchoolRank: state.mySchoolRank,
                            schoolInfo: state.schoolInfo,
                            openAdView: false
                        ))
                        
                    default:
                        break
                    }
                }
                
                return .run { send in
                    try await send(.dataResponse(self.searchResult.fetch([eSchoolUrl, mSchoolUrl, hSchoolUrl])))
                }
                
            case let .setMySchoolData(mySchool):
                state.mySchool = mySchool
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
