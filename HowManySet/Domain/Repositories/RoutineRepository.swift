//
//  RoutineRepository.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import Foundation
import RxSwift

/// 운동 루틴 관련 데이터의 저장, 조회, 수정, 삭제 기능을 제공하는 리포지토리 프로토콜입니다.
///
/// 로컬 또는 원격 데이터 소스와의 인터페이스를 정의합니다.
protocol RoutineRepository {
    
    /// 주어진 사용자 ID에 해당하는 운동 루틴 리스트를 비동기적으로 조회합니다.
    ///
    /// - Parameter uid: 운동 루틴을 조회할 사용자의 고유 식별자
    /// - Returns: `Single`로 감싸진 `WorkoutRoutine` 배열, 조회 성공 시 배열을 방출하고 실패 시 에러를 방출합니다.
    func fetchRoutine(uid: String?) -> Single<[WorkoutRoutine]>
    
    /// 주어진 사용자 ID에 해당하는 운동 루틴을 삭제합니다.
    ///
    /// - Parameters:
    ///   - uid: 운동 루틴을 삭제할 사용자의 고유 식별자
    ///   - item: 삭제할 `WorkoutRoutine` 객체
    func deleteRoutine(uid: String?, item: WorkoutRoutine)
    
    /// 주어진 사용자 ID에 해당하는 운동 루틴을 저장합니다.
    ///
    /// - Parameters:
    ///   - uid: 운동 루틴을 저장할 사용자의 고유 식별자
    ///   - item: 저장할 `WorkoutRoutine` 객체
    func saveRoutine(uid: String?, item: WorkoutRoutine)
    
    /// 주어진 사용자 ID에 해당하는 운동 루틴을 수정합니다.
    ///
    /// - Parameters:
    ///   - uid: 운동 루틴을 수정할 사용자의 고유 식별자
    ///   - item: 수정할 `WorkoutRoutine` 객체
    func updateRoutine(uid: String?, item: WorkoutRoutine)
}

// MARK: Realm Repository
extension RoutineRepository {
    
    func fetchRoutine() -> Single<[WorkoutRoutine]> {
        return fetchRoutine(uid: "")
    }
    
    func deleteRoutine(item: WorkoutRoutine) {
        deleteRoutine(uid: "", item: item)
    }
    
    func saveRoutine(item: WorkoutRoutine) {
        saveRoutine(uid: "", item: item)
    }
    
    func updateRoutine(item: WorkoutRoutine) {
        updateRoutine(uid: "", item: item)
    }
}
