//
//  FirestoreServiceProtocol.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation

/// Firestore 데이터베이스의 기본 CRUD 동작을 정의하는 프로토콜입니다.
protocol FirestoreServiceProtocol {
    
    /// Firestore에 문서를 생성(저장)합니다.
    /// - Parameters:
    ///   - item: 저장할 Firestore 문서 객체
    ///   - type: 저장할 Firestore 문서 타입
    /// - Returns: 생성된 문서의 ID
    func create<T: Codable>(item: T, type: FirestoreDataType<T>) async throws -> String
    
    /// 특정 타입의 모든 문서를 Firestore에서 조회합니다.
    /// - Parameter type: 조회할 Firestore 문서 타입
    /// - Returns: 조회된 문서들의 배열
    func read<T: Codable>(type: FirestoreDataType<T>) async throws -> [T]
    
    /// 특정 ID의 문서를 조회합니다.
    /// - Parameters:
    ///   - id: 조회할 문서의 ID
    ///   - type: 조회할 Firestore 문서 타입
    /// - Returns: 해당 ID의 Firestore 문서, 없을 경우 `nil`
    func read<T: Codable>(id: String, type: FirestoreDataType<T>) async throws -> T?
    
    /// 사용자별 문서를 조회합니다.
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - type: 조회할 Firestore 문서 타입
    /// - Returns: 해당 사용자의 문서들 배열
    func read<T: Codable>(userId: String, type: FirestoreDataType<T>) async throws -> [T]
    
    func updateWorkout(id: String, item: FSWorkout) async throws
    
    func updateRecord(id: String, item: FSWorkoutRecord) async throws
    
    func updateRoutine(id: String, item: FSWorkoutRoutine) async throws
    
    /// 특정 문서를 Firestore에서 삭제합니다.
    /// - Parameters:
    ///   - id: 삭제할 문서의 ID
    ///   - type: 삭제할 Firestore 문서 타입
    func delete<T: Codable>(id: String, type: FirestoreDataType<T>) async throws
    func deleteWorkout(id: String, item: FSWorkout) async throws
    
    /// 사용자별 특정 타입의 모든 문서를 삭제합니다.
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - type: 삭제할 Firestore 문서의 타입
    func deleteAll<T: Codable>(userId: String, type: FirestoreDataType<T>) async throws
}
