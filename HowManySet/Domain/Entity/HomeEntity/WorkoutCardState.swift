//
//  WorkoutCardState.swift
//  HowManySet
//
//  Created by 정근호 on 6/26/25.
//

import Foundation

/// 사용자에게 보여지는 운동 종목 카드 뷰의 정보를 담은 구조체
struct WorkoutCardState: Codable {
    /// 현재 운동종목의 ID
    var workoutID: String
    // UI에 직접 표시될 값들 (Reactor에서 미리 계산하여 제공)
    var currentExerciseName: String
    var currentWeight: Double
    var currentUnit: String
    var currentReps: Int
    /// 운동 세트 전체 정보
    var setInfo: [WorkoutSet]
    /// 현재 진행 중인 세트 인덱스
    var setIndex: Int
    /// 현재 루틴 안 운동종목의 인덱스
    var exerciseIndex: Int
    /// 전체 운동 개수
    var totalExerciseCount: Int
    /// 현재 운동의 전체 세트 개수
    var totalSetCount: Int
    /// UI용 "1 / N"에서 1
    var currentExerciseNumber: Int
    /// UI용 "1 / N"에서 1
    var currentSetNumber: Int
    /// 세트 프로그레스바
    var setProgressAmount: Int
    /// 현재 운동 종목의 메모
    var memoInExercise: String?
    var allSetsCompleted: Bool
    /// 현재 세트의 무게
    var currentWeightForSave: Double { setInfo[setIndex].weight }
    /// 현재 세트의 단위
    var currentUnitForSave: String { setInfo[setIndex].unit }
    /// 현재 세트의 반복수
    var currentRepsForSave: Int { setInfo[setIndex].reps }
}
