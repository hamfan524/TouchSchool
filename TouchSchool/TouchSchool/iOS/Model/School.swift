//
//  School.swift
//  TouchSchool
//
//  Created by 최동호 on 10/11/23.
//

import Alamofire
import FirebaseFirestoreSwift

import Foundation

struct schoolData: Decodable {
    var dataSearch: DataSearch
}

struct DataSearch: Decodable {
    var content: [School]
}

struct School: Decodable, Hashable, Identifiable {
    let id = UUID()

    var link: String
    var adres: String
    var schoolName: String
    var region: String
    var totalCount: String
    var estType: String
    var seq: String
    
    var dictionary: [String: Any] {
        return [
            "name": schoolName,
            "adres": adres,
            "seq": seq,
            "count": 0
        ]
    }
}

struct SchoolInfo: Decodable, Hashable, Identifiable {
    @DocumentID var id: String?

    var name: String
    var adres: String
    var seq: String
    var count: Int
    var rank: Int?
}

let headers: HTTPHeaders = [
    "Accept": "application/json"
]

var seqValue: String {
    get {
        UserDefaults.standard.string(forKey: "seqValue") ?? ""
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "seqValue")
    }
}

var pathId: String = ""

var allSchoolInfos = [SchoolInfo]()
var myID = ""
var mySchoolRank: Int = 0
var myTouchCount: Int {
    get {
        UserDefaults.standard.integer(forKey: "myTouchCount")
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "myTouchCount")
    }
}

let apiKey = Bundle.main.infoDictionary?["School_Api_Key"] ?? ""

let eSchoolUrl = "https://www.career.go.kr/cnet/openapi/getOpenApi?apiKey=\(apiKey)&svcType=api&svcCode=SCHOOL&contentType=json&gubun=elem_list&perPage=1000000"
let mSchoolUrl = "https://www.career.go.kr/cnet/openapi/getOpenApi?apiKey=\(apiKey)&svcType=api&svcCode=SCHOOL&contentType=json&gubun=midd_list&perPage=1000000"
let hSchoolUrl = "https://www.career.go.kr/cnet/openapi/getOpenApi?apiKey=\(apiKey)&svcType=api&svcCode=SCHOOL&contentType=json&gubun=high_list&perPage=1000000"
