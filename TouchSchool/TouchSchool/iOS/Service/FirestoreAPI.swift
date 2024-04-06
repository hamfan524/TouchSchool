//
//  SchoolFirestore.swift
//  TouchSchool
//
//  Created by 최동호 on 4/5/24.
//

import ComposableArchitecture
import FirebaseFirestore

import SwiftUI

protocol FirestoreAPI {
    func addSchool(school: School)
    func fetchSchool() async throws -> AsyncThrowingStream<[SchoolInfo], Error>
    func fetchMySchoolData() async throws -> AsyncThrowingStream<SchoolInfo, Error>
    func isSchoolExists(seq: String) async -> Bool

}

enum FirestoreAPIClientKey: DependencyKey {
    static var liveValue: FirestoreAPI = FirestoreAPIClient()
}

class FirestoreAPIClient: FirestoreAPI {
    
    private let db = Firestore.firestore()
    
    func addSchool(school: School) {
        db.collection("schools").addDocument(data: school.dictionary)
    }
    
    func fetchSchool() async throws -> AsyncThrowingStream<[SchoolInfo], Error> {
        AsyncThrowingStream<[SchoolInfo], Error> { continuation in
            let collection = db.collection("schools").order(by: "count", descending: true)
                                          
            collection.addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                
                do {
                    let schools = try querySnapshot?.documents.compactMap { document -> SchoolInfo? in
                        try document.data(as: SchoolInfo.self)
                    } ?? []

                    continuation.yield(schools)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    func fetchMySchoolData() async throws -> AsyncThrowingStream<SchoolInfo, Error> {
        AsyncThrowingStream<SchoolInfo, Error> { continuation in
            guard !seqValue.isEmpty else { return }
    
            db.collection("schools").whereField("seq", isEqualTo: seqValue).addSnapshotListener() { (querySnapshot, error) in
                guard error == nil else {
                    continuation.finish(throwing: error)
                    return
                }
                do {
                    let mySchoolData = try querySnapshot?.documents.compactMap { document -> SchoolInfo? in
                        try document.data(as: SchoolInfo.self)
                    } ?? []
                    
                    if let mySchool = mySchoolData.first {
                        continuation.yield(mySchool)
                    } else {
                        continuation.finish(throwing: error)
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    func isSchoolExists(seq: String) async -> Bool {
        do {
            let documents = try await db.collection("schools").whereField("seq", isEqualTo: seq)
                .getDocuments()
      
            if documents.isEmpty {
                return false
            } else {
                return true
            }
        } catch {
            print("문서 가져오기 오류: \(error.localizedDescription)")
        }
        return false
    }
 
}

extension DependencyValues {
    // SchoolFirestore
    var firestoreAPI: FirestoreAPI {
        get { self[FirestoreAPIClientKey.self] }
        set { self[FirestoreAPIClientKey.self] = newValue }
    }
    
}
