//
//  SchoolFirestore.swift
//  TouchSchool
//
//  Created by 최동호 on 4/5/24.
//

import ComposableArchitecture
import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseFirestore

import SwiftUI

protocol FirestoreAPI {
    func addSchool(school: School)
    func fetchSchool() async throws -> AsyncThrowingStream<[SchoolInfo], Error>
    func fetchMySchoolData() async throws -> AsyncThrowingStream<SchoolInfo, Error>
    func isSchoolExists(seq: String) async -> Bool
    func submitCount(schoolInfo: SchoolInfo, count: Int) -> Void

}

enum FirestoreAPIClientKey: DependencyKey {
    static var liveValue: FirestoreAPI = FirestoreAPIClient()
}

class FirestoreAPIClient: FirestoreAPI {
    
    private let db = Firestore.firestore()
    
    func addSchool(school: School) {
        db.collection("schools").addDocument(data: school.dictionary)
    }
    
    /*
     fetch: {
         do {
             @Dependency(\.databaseService.context) var context
             let itemContext = try context()
             let descriptor = FetchDescriptor<YouthPolicy>()
             return try itemContext.fetch(descriptor)
         } catch {
             throw SwiftDataError.fetchError
         }
     }
     */
    
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
    
    func submitCount(schoolInfo: SchoolInfo, count: Int) {
        let sfReference = db.collection("schools").document(schoolInfo.id ?? "")
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            guard let oldCount = sfDocument.data()?["count"] as? Int else {
                return nil
            }
            
            transaction.updateData(["count": oldCount + count], forDocument: sfReference)
            return nil
            
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
}

extension DependencyValues {
    // SchoolFirestore
    var firestoreAPI: FirestoreAPI {
        get { self[FirestoreAPIClientKey.self] }
        set { self[FirestoreAPIClientKey.self] = newValue }
    }
}
