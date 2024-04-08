//
//  SearchResult.swift
//  CleanArea
//
//  Created by 최동호 on 3/25/24.
//

import Alamofire
import ComposableArchitecture

import Foundation

struct SearchResult {
    var fetch: ([String]) async throws -> IdentifiedArrayOf<School>
}

extension SearchResult: DependencyKey {
    static let liveValue = Self(
        fetch: { Urls in
            var schools: [[School]] = []
            for url in Urls {
                let data = try await AF.request(url, method: .get, headers: headers).serializingDecodable(schoolData.self).value.dataSearch.content
                schools.append(data)
            }
            
            return IdentifiedArray(uniqueElements: schools.flatMap{ $0 })
        }
    )
}

extension DependencyValues {
    // searchApiResult
    var searchResult: SearchResult {
        get { self[SearchResult.self] }
        set { self[SearchResult.self] = newValue }
    }
}

