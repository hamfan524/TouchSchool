//
//  SearchBar.swift
//  TouchSchool
//
//  Created by 최동호 on 10/11/23.
//

import ComposableArchitecture

import SwiftUI

struct SearchBar: View {
    
    @Bindable var store: StoreOf<SearchFeature>
        
    var body: some View {
        ZStack(alignment: .leading) {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.grayText)
                        .padding(.leading, 10)
                    
                    TextField("",text: $store.text.sending(\.setText),
                              prompt: Text("검색").foregroundColor(.grayText)
                                .font(.custom("Giants-Bold", size: 16)))
                    .font(.custom("Giants-Bold", size: 16))
                    .tint(.white)
                    .frame(height: 20)
                    .padding(8)
                    .padding(.leading, -7)
                    .foregroundStyle(Color.white)
                    .accentColor(Color.white)
                    .cornerRadius(8)
                    .onTapGesture {
                        store.send(.focusTextField)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 10) // HStack의 크기에 맞게 동적으로 크기가 변하는 RoundedRectangle
                        .fill(Color.darkGrayText.opacity(0.3))
                )
                .overlay {
                    HStack {
                        Spacer()
                        if store.isEditing && !store.text.isEmpty {
                            if store.viewState == .loading {
                                Button {
                                    //
                                } label: {
                                    ProgressView()
                                        .tint(.white)
                                }
                                .padding(.trailing, 15)
                                .frame(width: 35, height: 35)
                            } else {
                                Button(action: {
                                    store.send(.clearTextField)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Color.grayText)
                                        .frame(width: 35, height: 35)
                                }
                                .padding(.trailing, 5)
                            }
                        }
                    }
                }
                if store.isEditing {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            store.send(.tabCancelButton)
                            hideKeyboard()
                        }
                    } label: {
                        Text("취소")
                            .font(.custom("Giants-Bold", size: 16))                 
                            .foregroundStyle(Color.white)
                    }
                    .padding(3)
                }
            }
        }
    }
}

