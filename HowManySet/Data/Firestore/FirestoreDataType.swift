//
//  FirestoreDataType.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation

/// Firestore 문서 타입을 제네릭으로 추상화하기 위한 프로토콜입니다.
/// 각 DTO 타입에 대해 타입 정보를 제공합니다.
protocol FirestoreDataTypeProtocol {
    associatedtype T: Codable
    /// Firestore 문서의 타입입니다.
    var type: T.Type { get }
    /// Firestore 컬렉션 이름입니다.
    var collectionName: String { get }
}

/// 다양한 Firestore DTO 타입을 나타내는 열거형입니다.
/// 타입 캐스팅을 통해 구체 타입 정보를 제공합니다.
enum FirestoreDataType<T: Codable>: FirestoreDataTypeProtocol {
    /// WorkoutRoutineDTO 타입
    case workoutRoutine
    /// WorkoutRecordDTO 타입
    case workoutRecord

    /// 각 케이스에 해당하는 Firestore 문서 타입 반환
    var type: T.Type {
        switch self {
        case .workoutRoutine:
            return FSWorkoutRoutine.self as! T.Type
        case .workoutRecord:
            return FSWorkoutRecord.self as! T.Type
        }
    }
    
    /// 각 케이스에 해당하는 Firestore 컬렉션 이름
    var collectionName: String {
        switch self {
        case .workoutRoutine:
            return "workout_routines"
        case .workoutRecord:
            return "workout_records"
        }
    }
}

/// Firestore 작업 중 발생할 수 있는 오류 유형입니다.
enum FirestoreErrorType: Error {
    /// 데이터를 찾을 수 없는 경우
    case dataNotFound
    /// 네트워크 연결 오류
    case networkError
    /// 인증 오류
    case authenticationError
    /// 권한 오류
    case permissionDenied
    /// 문서 ID가 유효하지 않은 경우
    case invalidDocumentID
}
