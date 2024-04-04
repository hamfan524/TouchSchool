//
//  SearchFeature.swift
//  TouchSchool
//
//  Created by 최동호 on 4/4/24.
//

import ComposableArchitecture

import SwiftUI

@Reducer
struct SearchFeature {
    @ObservableState
    struct State: Equatable {
        var isEditing: Bool = false
        var schools: IdentifiedArrayOf<School>
        var filteredSchools: IdentifiedArrayOf<School> = []
        var text: String = ""
        var viewState: ViewState = ViewState.empty
    }
    
    enum Action {
        case clearTextField
        case filteringSchools
        case setSchools(IdentifiedArrayOf<School>)
        case setText(String)
        case setViewState(ViewState)
        case selectSchool(School)
        case tabBackButton
        case tabCancelButton
        case focusCancelTextField
        case focusTextField
    }
    
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .clearTextField:
                state.text = ""
                return .none
            
            case .filteringSchools:
                return .run { [text = state.text,
                               schools = state.schools] send in
                    let filteredSchools = schools.filter { $0.schoolName.contains(text) }
                    if filteredSchools.isEmpty {
                        await send(.setViewState(ViewState.empty))
                    } else {
                        await send(.setSchools(filteredSchools))
                    }
                }
                
            case .focusCancelTextField:
                withAnimation {
                    state.isEditing = false
                }
                return .none
                
            case .focusTextField:
                withAnimation {
                    state.isEditing = true
                }
                return .none
            
            case let .setSchools(schools):
                state.filteredSchools = schools
                return .run { send in
                    await send(.setViewState(ViewState.ready))
                }
                
            case let .setText(text):
                state.text = text
                return .run { send in
                    await send(.setViewState(ViewState.loading))
                    try await Task.sleep(for: .seconds(1))
                    await send(.filteringSchools)
                }
                
            case let .setViewState(viewState):
                state.viewState = viewState
                return .none
                
            case let .selectSchool(school):
                let firebaseManager = FirebaseManager(school: school)
                
                firebaseManager.isSchoolExists(seq: school.seq) { exists in
                    if !exists {
                        firebaseManager.addSchool(a: school)
                    }
                    seqValue = school.seq
                    myTouchCount = 0
                }
                
                return .run { send in
                    await send(.tabBackButton)
                }
            
            case .tabBackButton:
                return .run { _ in
                    await self.dismiss()
                }
            
            case .tabCancelButton:
                return .run { send in
                    await send(.clearTextField)
                    await send(.focusCancelTextField)
                }
            }
        }
    }
}
