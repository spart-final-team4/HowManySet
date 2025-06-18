//
//  WorkoutRepositoryProtocol.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation
import RxSwift

/// 운동 데이터에 대한 저장소 인터페이스입니다.
/// 로컬 저장소(Realm)와 원격 저장소(Firestore)를 함께 사용하여 데이터 동기화를 제공합니다.
protocol WorkoutRepositoryProtocol {
    
    /// 운동을 저장합니다 (로컬 + 클라우드 동기화)
    /// - Parameters:
    ///   - uid: 사용자 식별자
    ///   - item: 저장할 운동 엔티티
    /// - Returns: 저장된 문서 ID를 Single로 반환
    func saveWorkout(uid: String, item: Workout) -> Single<String>
    
    /// 운동 목록을 불러옵니다 (로컬 우선, 없으면 클라우드에서 조회)
    /// - Parameter uid: 사용자 식별자
    /// - Returns: 운동 목록을 RxSwift Single 형태로 반환
    func fetchWorkouts(uid: String) -> Single<[Workout]>
    
    /// 특정 운동을 삭제합니다 (로컬 + 클라우드)
    /// - Parameters:
    ///   - uid: 사용자 식별자
    ///   - item: 삭제할 운동
    /// - Returns: 삭제 완료를 Single로 반환
    func deleteWorkout(uid: String, item: Workout) -> Single<Void>
    
    /// 운동을 업데이트합니다 (로컬 + 클라우드)
    /// - Parameters:
    ///   - uid: 사용자 식별자
    ///   - item: 업데이트할 운동
    /// - Returns: 업데이트 완료를 Single로 반환
    func updateWorkout(uid: String, item: Workout) -> Single<Void>
    
    /// 사용자의 모든 운동을 삭제합니다
    /// - Parameter uid: 사용자 식별자
    /// - Returns: 삭제 완료를 Single로 반환
    func deleteAllWorkouts(uid: String) -> Single<Void>
}
