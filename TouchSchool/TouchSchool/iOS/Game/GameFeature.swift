//
//  GameFeature.swift
//  TouchSchool
//
//  Created by 최동호 on 4/6/24.
//

import ComposableArchitecture

import AVKit
import SwiftUI

@Reducer
struct GameFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var alert: AlertState<Action.Alert>?
        var animationAmount = 0.0
        var isTimerRunning = false
        var mySchool: SchoolInfo
        var mySchoolRank: Int
        var schoolInfo: IdentifiedArrayOf<SchoolInfo>
        var smokes: IdentifiedArrayOf<Smoke> = []
        var touchCount: Int = 0
    }
    
    enum Action {
        case alert(PresentationAction<Alert>)
        case handelCount
        case setMySchoolRank
        case submitCount
        case smokeAnimaition(Smoke)
        case tabBackButton
        case touchScreen(CGPoint)

        enum Alert: Equatable {
            case warningAlert
        }
    }

    enum CancelID { case timer }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.firestoreAPI) var firestoreAPI

    let soundSetting = SoundSetting.instance

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .handelCount:
                state.touchCount += 1
                if !state.isTimerRunning {
                    state.isTimerRunning = true
                    return .run { send in
                        try await Task.sleep(for: .seconds(5))
                        await send(.submitCount)
                    }
                    .cancellable(id: CancelID.timer)
                }
                return .none

            case .setMySchoolRank:
                let myRank = state.schoolInfo.firstIndex(where: { $0.seq == seqValue }) ?? (state.schoolInfo.count - 1)
                state.mySchoolRank = myRank + 1
                return .none
                
            case .submitCount:
                if state.touchCount >= 230 {
                    soundSetting.playSound(sound: .errorBGM)
                    state.touchCount = 0
                    state.alert = AlertState {
                        TextState("비정상적인 터치수가 감지되었습니다.")
                    } actions: {
                        ButtonState(role: .cancel, action: .warningAlert) {
                            TextState("확인")
                        }
                    }
                } else {
                    firestoreAPI.submitCount(schoolInfo: state.mySchool, count: state.touchCount)
                    myTouchCount += state.touchCount
                    state.touchCount = 0
                }
                state.isTimerRunning = false
                return .cancel(id: CancelID.timer)
                
            case let .smokeAnimaition(smoke):
                withAnimation(.linear(duration: 1)) {
                    state.smokes[state.smokes.firstIndex(where: { $0.id == smoke.id })!].opacity = 0
                    state.smokes[state.smokes.firstIndex(where: { $0.id == smoke.id })!].angle += 30
                }
                return .none
                
            case .tabBackButton:
                return .run { _ in
                    await self.dismiss()
                }
                
            case let .touchScreen(location):
                soundSetting.playSound(sound: .buttonBGM)
                let angle = Double.random(in: -30...30)
                let newSmoke = Smoke(location: location,
                                     showEffect: true,
                                     angle: angle,
                                     opacity: 1)
                if state.smokes.count >= 30 {
                    state.smokes.removeFirst()
                }
                state.smokes.append(newSmoke)
                
                withAnimation {
                    state.animationAmount += 360
                }
                
                return .run { send in
                    await send(.handelCount)
                }
            
            case .alert(.presented(.warningAlert)):
                            
                return .none

            case .alert(_):
                return .none
            }
        }
    }
}
