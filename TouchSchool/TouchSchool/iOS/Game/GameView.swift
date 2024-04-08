//
//  GameView.swift
//  TouchSchool
//
//  Created by 최동호 on 10/11/23.
//

import ComposableArchitecture

import SwiftUI

struct GameView: View {
    @Bindable var store: StoreOf<GameFeature>
    
    var body: some View {
        ZStack {
            Image("blackboard_set")
                .resizable()
                .ignoresSafeArea()
            VStack {
                Spacer()
                
                HStack {
                    Text("\(store.mySchoolRank)위")
                        .foregroundStyle(.mint)
                        .font(.custom("Giants-Bold", size: 30))
                        .bold()
                    Text("\(store.mySchool.name)")
                        .foregroundStyle(.mint)
                        .font(.custom("Giants-Bold", size: 30))
                        .bold()
                }
                Text("\(myTouchCount + store.touchCount)")
                    .foregroundStyle(.white)
                    .font(.custom("Giants-Bold", size: 60))
                    .bold()
                    .padding()
                
                Spacer()
                
                Image("11111")
                    .resizable()
                    .frame(width: 120, height: 80)
                    .rotation3DEffect(
                        .degrees(store.animationAmount),
                        axis: (x: 0.0, y: 1.0, z: 0.0))
                
                Spacer()
                
                HStack {
                    Image("achievement-1293132_1280")
                        .resizable()
                        .frame(width: 40, height: 50)
                    
                    Text("\(store.mySchool.count)")
                        .foregroundStyle(.white)
                        .font(.custom("Giants-Bold", size: 50))
                }
                .padding()
                Spacer()
            }
            
            ForEach(store.smokes) { smoke in
                if smoke.showEffect {
                    SmokeEffectView(smoke: smoke)
                        .rotationEffect(.degrees(smoke.angle))
                        .opacity(smoke.opacity)
                        .offset(x: smoke.location.x - UIScreen.main.bounds.width / 2,
                                y: smoke.location.y - UIScreen.main.bounds.height / 2)
                        .onAppear {
                            store.send(.smokeAnimaition(smoke))
                        }
                }
            }
            MultitouchRepresentable { location in
                store.send(.touchScreen(location))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack{
                HStack{
                    Button(action: {
                        store.send(.tabBackButton)
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color.grayText)
                            .imageScale(.large)
                        Text("돌아가기")
                            .font(.custom("Giants-Bold", size: 15))
                            .foregroundColor(Color.grayText)
                    }
                    .padding(.leading)
                    Spacer()
                }
                .padding(.top)
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}


