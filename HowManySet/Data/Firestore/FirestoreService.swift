//
//  FirestoreService.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation
import FirebaseFirestore

/// Firestore 데이터베이스에 대한 기본적인 CRUD 기능을 제공하는 클래스입니다.
/// `FirestoreServiceProtocol`을 구현하며, Firestore 문서를 생성, 조회, 수정, 삭제할 수 있습니다.
final class FirestoreService: FirestoreServiceProtocol {
    
    /// Firestore 인스턴스
    private let db = Firestore.firestore()

    /// FirestoreService 객체 초기화
    init() {}

    /// Firestore에 문서를 생성(저장)합니다.
    /// - Parameters:
    ///   - item: 저장할 Firestore 문서 객체
    ///   - type: 저장할 Firestore 문서 타입
    /// - Returns: 생성된 문서의 ID
    func create<T: Codable>(item: T, type: FirestoreDataType<T>) async throws -> String {
        do {
            let docRef = try await db.collection(type.collectionName).addDocument(from: item)
            return docRef.documentID
        } catch {
            print("create Failed: \(error.localizedDescription)")
            throw FirestoreErrorType.networkError
        }
    }

    /// Firestore에서 특정 타입의 문서 목록을 조회합니다.
    /// - Parameter type: 조회할 Firestore 문서 타입
    /// - Returns: 조회된 문서들의 배열
    func read<T: Codable>(type: FirestoreDataType<T>) async throws -> [T] {
        do {
            let snapshot = try await db.collection(type.collectionName).getDocuments()
            return try snapshot.documents.compactMap { document in
                try document.data(as: type.type)
            }
        } catch {
            print("read Failed: \(error.localizedDescription)")
            throw FirestoreErrorType.dataNotFound
        }
    }

    /// Firestore에서 특정 ID에 해당하는 문서를 조회합니다.
    /// - Parameters:
    ///   - id: 조회할 문서의 ID
    ///   - type: 조회할 Firestore 문서 타입
    /// - Returns: 조회된 문서가 존재하면 반환, 없으면 `nil`
    func read<T: Codable>(id: String, type: FirestoreDataType<T>) async throws -> T? {
        do {
            let document = try await db.collection(type.collectionName).document(id).getDocument()
            return try document.data(as: type.type)
        } catch {
            print("read by ID Failed: \(error.localizedDescription)")
            return nil
        }
    }

    /// 사용자별 문서를 조회합니다.
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - type: 조회할 Firestore 문서 타입
    /// - Returns: 해당 사용자의 문서들 배열
    func read<T: Codable>(userId: String, type: FirestoreDataType<T>) async throws -> [T] {
        do {
            let snapshot = try await db.collection(type.collectionName)
                .whereField("user_id", isEqualTo: userId)
                .getDocuments()
            
            return try snapshot.documents.compactMap { document in
                try document.data(as: type.type)
            }
        } catch {
            print("read by userId Failed: \(error.localizedDescription)")
            throw FirestoreErrorType.dataNotFound
        }
    }
    
    func updateRoutine(id: String, item: FSWorkoutRoutine) async throws {
        do {
            try db.collection("workout_routines").document(id).setData(from: item)
        } catch {
            print("update failed: \(error.localizedDescription)")
            throw FirestoreErrorType.networkError
        }
    }
    
    func updateWorkout(id: String, item: FSWorkout) async throws {
        do {
            let docRef = db.collection("workout_routines").document(id)
            
            // 문서 가져오기
            let snapshot = try await docRef.getDocument()
            var routine = try snapshot.data(as: FSWorkoutRoutine.self)
            
            // 기존 workouts에서 id 매칭해서 업데이트
            if let index = routine.workouts.firstIndex(where: { $0.uuid == item.uuid }) {
                routine.workouts[index] = item
                routine.updatedAt = Date() // 선택적으로 업데이트 시간 갱신
            } else {
                throw NSError(domain: "WorkoutUpdate", code: 404, userInfo: [NSLocalizedDescriptionKey: "Workout not found in record"])
            }
            
            // 업데이트 수행 (전체 교체)
            try docRef.setData(from: routine, merge: true)
        } catch {
            print("update failed: \(error.localizedDescription)")
            throw FirestoreErrorType.networkError
        }
    }
    
    func updateRecord(id: String, item: FSWorkoutRecord) async throws {
        do {
            let querySnapshot = try await db.collection("workout_records").whereField("uuid", isEqualTo: item.uuid).getDocuments()
            
            guard let document = querySnapshot.documents.first else {
                return
            }
            
            let docRef = document.reference
            
            try await docRef.updateData(["comment": item.comment ?? ""])
        } catch {
            print("update failed: \(error.localizedDescription)")
            throw FirestoreErrorType.networkError
        }
    }

    /// Firestore에서 특정 문서를 삭제합니다.
    /// - Parameters:
    ///   - id: 삭제할 문서의 ID
    ///   - type: 삭제할 Firestore 문서 타입
    func delete<T: Codable>(id: String, type: FirestoreDataType<T>) async throws {
        do {
            try await db.collection(type.collectionName).document(id).delete()
        } catch {
            print("delete Failed: \(error.localizedDescription)")
            throw FirestoreErrorType.networkError
        }
    }
    
    func deleteWorkout(id: String, item: FSWorkout) async throws {
        do {
            let docRef = db.collection("workout_routines").document(id)
            let snapshot = try await docRef.getDocument()
            guard let data = snapshot.data(),
                  var workouts = data["workouts"] as? [[String: Any]] else {
                throw FirestoreErrorType.dataNotFound
            }
            
            let encoder = Firestore.Encoder()
            let deletedWorkout = try encoder.encode(item) as [String: Any]
            workouts.removeAll { $0["uuid"] as? String == deletedWorkout["uuid"] as? String }
            
            try await docRef.updateData(["workouts": workouts])
        } catch {
            throw FirestoreErrorType.networkError
        }
    }

    /// 사용자별 특정 타입의 모든 문서를 삭제합니다.
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - type: 삭제할 Firestore 문서의 타입
    func deleteAll<T: Codable>(userId: String, type: FirestoreDataType<T>) async throws {
        do {
            let snapshot = try await db.collection(type.collectionName)
                .whereField("user_id", isEqualTo: userId)
                .getDocuments()
            
            let batch = db.batch()
            
            for document in snapshot.documents {
                batch.deleteDocument(document.reference)
            }
            
            try await batch.commit()
        } catch {
            print("delete All by userId Failed: \(error.localizedDescription)")
            throw FirestoreErrorType.networkError
        }
    }
}
