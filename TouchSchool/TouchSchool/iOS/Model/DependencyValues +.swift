//
//  DependencyValues +.swift
//  CleanArea
//
//  Created by 최동호 on 3/31/24.
//

import ComposableArchitecture

import Foundation

extension DependencyValues {
    // searchApiResult
    var searchResult: SearchResult {
        get { self[SearchResult.self] }
        set { self[SearchResult.self] = newValue }
    }
}
