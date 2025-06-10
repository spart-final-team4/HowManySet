//
//  WorkoutRoutineDTO.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation
import RealmSwift

/// 운동 루틴 정보를 나타내는 Realm 객체입니다.
/// 루틴 이름과 포함된 운동 목록을 저장합니다.
final class WorkoutRoutineDTO: Object {
    /// 운동 루틴의 이름입니다. 예: "상체 루틴"
    @Persisted var name: String

    /// 루틴에 포함된 운동 목록입니다. `WorkoutDTO` 객체의 리스트로 구성됩니다.
    @Persisted var workouts = List<WorkoutDTO>()
    
    /// 세트 간 휴식 시간(초)입니다.
    @Persisted var restTime: Int

    /// 운동 리스트를 배열 형태로 다룰 수 있도록 하는 계산 속성입니다.
    var workoutArray: [WorkoutDTO] {
        get {
            return workouts.map { $0 }
        }
        set {
            workouts.removeAll()
            workouts.append(objectsIn: newValue)
        }
    }

    /// 주어진 값들로 `WorkoutRoutineDTO` 객체를 초기화합니다.
    /// - Parameters:
    ///   - name: 루틴 이름
    ///   - workouts: 포함된 운동들의 배열
    convenience init(
        name: String,
        workouts: [WorkoutDTO]
    ) {
        self.init()
        self.name = name
        self.workoutArray = workouts
    }
}

extension WorkoutRoutineDTO {
    /// DTO 객체를 도메인 모델 `WorkoutRoutine`으로 변환합니다.
    /// - Returns: 동일한 정보를 가진 `WorkoutRoutine` 도메인 객체
    func toEntity() -> WorkoutRoutine {
        return WorkoutRoutine(name: self.name,
                              workouts: self.workouts.map { $0.toEntity() }, restTime: self.restTime)
    }
}

extension WorkoutRoutineDTO {
    /// 도메인 모델 `WorkoutRoutine`을 기반으로 `WorkoutRoutineDTO`를 초기화합니다.
    /// - Parameter entity: 변환할 `WorkoutRoutine` 도메인 객체
    convenience init(entity: WorkoutRoutine) {
        self.init()
        self.name = entity.name
        self.workoutArray = entity.workouts.map { WorkoutDTO(entity: $0) }
    }
}
