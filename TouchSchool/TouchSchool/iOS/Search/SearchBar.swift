//
//  SearchBar.swift
//  TouchSchool
//
//  Created by 최동호 on 10/11/23.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @Binding var isLoading: Bool
    
    @State private var isEditing = false
    @State var isFocused: Bool = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.grayText)
                        .padding(.leading, 10)
                    
                    TextField("",text: $text,
                              prompt: Text("검색").foregroundColor(.grayText)
                                .font(.custom("Giants-Bold", size: 16)))
                    .tint(.white)
                    .frame(height: 20)
                    .padding(8)
                    .padding(.leading, -7)
                    .foregroundStyle(Color.white)
                    .accentColor(Color.white)
                    .cornerRadius(8)
                    .onTapGesture {
                        withAnimation {
                            isEditing = true
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 10) // HStack의 크기에 맞게 동적으로 크기가 변하는 RoundedRectangle
                        .fill(Color.darkGrayText.opacity(0.3))
                )
                .overlay {
                    HStack {
                        Spacer()
                        if isEditing && !text.isEmpty {
                            if isLoading {
                                Button {
                                    text = ""
                                } label: {
                                    ProgressView()
                                        .tint(.white)
                                }
                                .padding(.trailing, 15)
                                .frame(width: 35, height: 35)
                            } else {
                                Button(action: {
                                    text = ""
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
                if isEditing {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            text = ""
                            isEditing = false
                            hideKeyboard()
                        }
                    } label: {
                        Text("취소")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.white)
                    }
                    .padding(3)
                }
            }
        }
    }
}

