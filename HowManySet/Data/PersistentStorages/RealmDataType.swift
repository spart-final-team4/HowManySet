//
//  RealmDataType.swift
//  HowManySet
//
//  Created by MJ Dev on 6/9/25.
//

import Foundation
import RealmSwift

/// Realm 객체 타입을 제네릭으로 추상화하기 위한 프로토콜입니다.
/// 각 DTO 타입에 대해 타입 정보를 제공합니다.
protocol RealmDataTypeProtocol {
    associatedtype T: Object
    /// Realm 객체의 타입입니다.
    var type: T.Type { get }
}

/// 다양한 Realm DTO 타입을 나타내는 열거형입니다.
/// 타입 캐스팅을 통해 구체 타입 정보를 제공합니다.
enum RealmDataType<T: Object>: RealmDataTypeProtocol {
    /// WorkoutDTO 타입
    case workout
    /// WorkoutRoutineDTO 타입
    case workoutRoutine
    /// WorkoutRecordDTO 타입
    case workoutRecord

    /// 각 케이스에 해당하는 Realm 객체 타입 반환
    var type: T.Type {
        switch self {
        case .workout:
            return RMWorkout.self as! T.Type
        case .workoutRoutine:
            return RMWorkoutRoutine.self as! T.Type
        case .workoutRecord:
            return RMWorkoutRecord.self as! T.Type
        }
    }
}

/// Realm 작업 중 발생할 수 있는 오류 유형입니다.
enum RealmErrorType: Error {
    /// 데이터를 찾을 수 없는 경우
    case dataNotFound
}
