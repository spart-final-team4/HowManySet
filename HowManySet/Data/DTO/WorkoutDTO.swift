//
//  WorkoutDTO.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation
import RealmSwift

/// 하나의 운동(workout)을 나타내는 Realm 객체입니다.
/// 운동 이름, 세트 정보, 휴식 시간, 코멘트 등을 포함합니다.
final class WorkoutDTO: Object {
    /// 운동 이름입니다. 예: "벤치 프레스"
    @Persisted var name: String

    /// 운동에 대한 메모 또는 코멘트 (옵션)
    @Persisted var comment: String?

    /// 운동에 포함된 세트 목록입니다. `WorkoutSetDTO` 객체의 리스트입니다.
    @Persisted var sets = List<WorkoutSetDTO>()

    /// 세트 리스트를 배열 형태로 다룰 수 있도록 하는 계산 속성입니다.
    var setArray: [WorkoutSetDTO] {
        get {
            return sets.map { $0 }
        }
        set {
            sets.removeAll()
            sets.append(objectsIn: newValue)
        }
    }

    /// 주어진 값들로 `WorkoutDTO` 객체를 초기화합니다.
    /// - Parameters:
    ///   - name: 운동 이름
    ///   - sets: 세트 배열
    ///   - restTime: 세트 간 휴식 시간(초)
    ///   - comment: 운동에 대한 메모 (옵션)
    convenience init(
        name: String,
        sets: [WorkoutSetDTO],
        restTime: Int,
        comment: String? = nil
    ) {
        self.init()
        self.name = name
        self.comment = comment
        self.setArray = sets
    }
}

extension WorkoutDTO {
    /// DTO 객체를 도메인 모델 `Workout`으로 변환합니다.
    /// - Returns: 동일한 정보를 가진 `Workout` 도메인 객체
    func toEntity() -> Workout {
        return Workout(name: self.name,
                       sets: self.sets.map { $0.toEntity() },
                       comment: self.comment)
    }
}

extension WorkoutDTO {
    /// 도메인 모델 `Workout`을 기반으로 `WorkoutDTO`를 초기화합니다.
    /// - Parameter entity: 변환할 `Workout` 도메인 객체
    convenience init(entity: Workout) {
        self.init()
        self.name = entity.name
        self.comment = entity.comment
        self.setArray = entity.sets.map { WorkoutSetDTO(entity: $0) }
    }
}

