//
//  RoutineRepositoryImpl.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import Foundation
import RxSwift

/// `RoutineRepository` 프로토콜을 구현한 운동 루틴 저장소 클래스입니다.
///
/// 실제 데이터 소스(예: 데이터베이스, 네트워크 등)와 연동하여 운동 루틴을 조회, 저장, 수정, 삭제하는 기능을 제공합니다.
final class RoutineRepositoryImpl: RoutineRepository {
    
    private let realmService: RealmServiceProtocol
    
    init(realmService: RealmServiceProtocol) {
        self.realmService = realmService
    }
    
    /// 주어진 사용자 ID에 해당하는 운동 루틴 리스트를 비동기적으로 조회합니다.
    ///
    /// - Parameter uid: 운동 루틴을 조회할 사용자의 고유 식별자
    /// - Returns: `Single`로 감싸진 `WorkoutRoutine` 배열, 조회 성공 시 배열을 방출하고 실패 시 에러를 방출합니다.
    func fetchRoutine(uid: String) -> Single<[WorkoutRoutine]> {
        return Single.create { [weak self] observer in
            guard let routines = self?.realmService.read(type: .workoutRecord) else {
                observer(.failure(RealmErrorType.dataNotFound))
                return Disposables.create()
            }
             
            let routineDTO: [WorkoutRoutineDTO] = routines.map{ ($0 as! RMWorkoutRoutine).toDTO()}
            // 예시: 빈 배열 반환
            observer(.success(routineDTO.map{$0.toEntity()}))
            
            return Disposables.create()
        }
    }
    
    /// 주어진 사용자 ID에 해당하는 운동 루틴을 삭제합니다.
    ///
    /// - Parameters:
    ///   - uid: 운동 루틴을 삭제할 사용자의 고유 식별자
    ///   - item: 삭제할 `WorkoutRoutine` 객체
    func deleteRoutine(uid: String, item: WorkoutRoutine) {
        let routine = RMWorkoutRoutine(dto: WorkoutRoutineDTO(entity: item))
        realmService.delete(item: routine)
    }
    
    /// 주어진 사용자 ID에 해당하는 운동 루틴을 저장합니다.
    ///
    /// - Parameters:
    ///   - uid: 운동 루틴을 저장할 사용자의 고유 식별자
    ///   - item: 저장할 `WorkoutRoutine` 객체
    func saveRoutine(uid: String, item: WorkoutRoutine) {
        let routine = RMWorkoutRoutine(dto: WorkoutRoutineDTO(entity: item))
        realmService.create(item: routine)
    }
    
    /// 주어진 사용자 ID에 해당하는 운동 루틴을 수정합니다.
    ///
    /// - Parameters:
    ///   - uid: 운동 루틴을 수정할 사용자의 고유 식별자
    ///   - item: 수정할 `WorkoutRoutine` 객체 덮어쓰기
    func updateRoutine(uid: String, item: WorkoutRoutine) {
        // TODO: 운동 루틴 수정 구현 (테스트 필요)
        let routines = realmService.read(type: .workoutRoutine)
        routines?.forEach{ object in
            realmService.update(item: object) { routine in
                let data = routine as! RMWorkoutRoutine
                if data.name == item.name {
                    data.workoutArray = item.workouts.map{ RMWorkout(dto: WorkoutDTO(entity: $0)) }
                }
            }
        }
    }
}

