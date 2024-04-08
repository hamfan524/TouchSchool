//
//  MainTests.swift
//  TouchSchool
//
//  Created by 노주영 on 4/8/24.
//

import ComposableArchitecture
import FirebaseFirestore
import FirebaseFirestoreSwift

import XCTest
@testable import TouchSchool

@MainActor
final class MainTests: XCTestCase {
    let mok1: School = School(link: "http://gageodo.es.jne.kr/", adres: "전라남도 신안군 흑산면 가거도길 18-31(흑산면)", schoolName: "가거도초등학교", region: "전라남도", totalCount: "6327", estType: "공립", seq: "4491")
    
    let mok2: SchoolInfo = SchoolInfo(
        id: "SL2v5zpM36ZMuwaPPV9X",
        name: "인덕원고등학교",
        adres: "경기도 안양시 동안구 안양판교로 43(관양동,인덕원고등학교)",
        seq: "1061",
        count: 6103,
        rank: nil
    )
    /*
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
     */
    
    func testfetchData() async {
        let store = TestStore(initialState: MainFeature.State(
            mySchool: mok2,
            mySchoolRank: 1,
            schools: [],
            schoolInfo: IdentifiedArrayOf(uniqueElements: [mok2]),
            isDownloading: true
        )) {
            MainFeature()
        } withDependencies: {
            $0.searchResult.fetch = { _ in
                IdentifiedArrayOf(uniqueElements: [self.mok1])
            }
        }
        
        await store.send(.fetchData)
        
        await store.receive(\.fetchMySchoolData, timeout: .seconds(10.0))
        
        await store.receive(\.rankDataResponse, timeout: .seconds(10.0)) {
            $0.schoolInfo = [self.mok2]
            $0.mySchoolRank = 9
        }
        
        await store.receive(\.setMySchoolData, timeout: .seconds(10.0)) {
            $0.mySchool = self.mok2
        }
        
        await store.receive(\.dataResponse, timeout: .seconds(10.0)) {
            $0.schools = IdentifiedArrayOf(uniqueElements: [self.mok1])
        }
        
        await store.receive(\.openMain) {
            $0.isDownloading = false
        }
        
        await store.finish(timeout: .seconds(42.0))
    }
}
