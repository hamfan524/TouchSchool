//
//  GridCell.swift
//  TouchSchool
//
//  Created by 최동호 on 12/18/23.
//

import SwiftUI

struct GridCell: View {
    let intro: Introduce
    var body: some View {
        Link(destination: URL(string: intro.url)!) {
            VStack {
                Image(intro.imageName ?? "")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(.rect(cornerRadius: 10))
                Text(intro.name)
                    .font(.custom("Giants-Bold", size: 15))
                    .foregroundStyle(.white)
            }
        }
    }
}
