//
//  ContentView.swift
//  TouchSchool
//
//  Created by 최동호 on 10/11/23.
//

import ComposableArchitecture

import SwiftUI

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

