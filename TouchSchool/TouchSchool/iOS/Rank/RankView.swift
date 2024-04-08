
//
//  RankView.swift
//  TouchSchool
//
//  Created by 최동호 on 10/11/23.
//

import ComposableArchitecture

import SwiftUI

struct RankView: View {
    @Bindable var store: StoreOf<RankFeature>
    
    var body: some View {
        ZStack {
            if store.openAdView {
                InterstitialAdView()
                    .onAppear {
                        store.send(.closeAd)
                    }
            }
            
            Image("blackboard_set")
                .resizable()
                .ignoresSafeArea()
            
            //꾸밈화면
            VStack {
                //돌아가기
                HStack {
                    Button(action: {
                        // Handle back button action here
                        store.send(.tabBackButton)
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .imageScale(.large)
                        Text("돌아가기")
                            .font(.custom("Giants-Bold", size: 15))
                            .foregroundColor(.white)
                    }
                    .padding(.leading)
                    Spacer()
                }
                
                //우리학교 순위
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.darkGrayText.opacity(0.5))
                        .frame(height: 130)
                        .padding()
                    
                    VStack {
                        Text("\(store.mySchool.name)")
                            .foregroundStyle(.mint)
                            .font(.custom("Giants-Bold", size: 30))
                            .padding(.top)
                        
                        HStack {
                            Text("\(store.mySchoolRank)위 ")
                                .foregroundStyle(.white)
                                .font(.custom("Giants-Bold", size: 30))
                            
                            Text("\(store.mySchool.count)")
                                .foregroundStyle(.white)
                                .font(.custom("Giants-Bold", size: 30))
                            
                        }
                        .padding()
                    }
                }
                
                // 학교 순위리스트
                List {
                    LazyVStack(alignment: .leading) {
                        ForEach(store.schoolInfo.indices) { index in
                            HStack {
                                Text("\(index + 1)위 ")
                                        .font(.custom("Giants-Bold", size: 15))
                                
                                Text(store.schoolInfo[index].name)
                                    .font(.custom("Giants-Bold", size: 15))
                                    .frame(width: 150, height: 25, alignment: .leading)
                                
                                Text("\(store.schoolInfo[index].count)")
                                    .font(.custom("Giants-Bold", size: 15))
                            }
                            .foregroundColor(.white)
                            .bold()
                        }
                    }
                    .listRowBackground(Color.darkGrayText.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            Spacer()
        }
        .navigationBarBackButtonHidden()
    }
}
