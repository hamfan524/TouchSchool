//
//  SearchView.swift
//  TouchSchool
//
//  Created by 최동호 on 10/11/23.
//

import ComposableArchitecture

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    
    @Bindable var store: StoreOf<SearchFeature>
    
    var body: some View {

        ZStack{
            Image("blackboard_set")
                .resizable()
                .ignoresSafeArea()
            VStack{
                HStack{
                    Button(action: {
                        store.send(.tabBackButton)
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color.white)
                            .imageScale(.large)
                        Text("돌아가기")
                            .font(.custom("Giants-Bold", size: 15))
                            .foregroundColor(Color.white)
                    }
                    .padding(.leading)
                    Spacer()
                }
                SearchBar(store: store)
                    .padding()
                VStack{
                    if store.text.isEmpty {
                        SearchGuide()
                    } else if store.viewState == .empty {
                        Text("검색 결과가 없습니다.")
                            .foregroundColor(Color.grayText)
                            .font(.custom("Giants-Bold", size: 10))
                            .bold()
                            .padding(.top, 150)
                        
                    } else if store.viewState == .ready {
                        
                        List(store.filteredSchools) { school in
                            Button(action: {
                                store.send(.tabSchoolCell(school))
                            }) {
                                VStack(alignment: .leading) {
                                    Text(school.schoolName)
                                        .font(.custom("Giants-Bold", size: 15))
                                        .foregroundColor(.white)
                                    Text(school.adres)
                                        .font(.custom("Giants-Bold", size: 15))
                                        .foregroundColor(Color.grayText)
                                }
                            }
                            .listRowBackground(Color.darkGrayText.opacity(0.5))
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)

                    }
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
