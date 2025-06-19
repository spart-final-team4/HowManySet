//
//  WorkoutStatistics.swift
//  HowManySet
//
//  Created by GO on 6/18/25.
//

import Foundation

/// 사용자의 운동 통계 정보를 나타내는 구조체입니다.
///
/// UseCase에서 계산된 운동 관련 통계 데이터를 캡슐화합니다.
/// 운동 진행도 추적 및 성과 분석에 활용됩니다.
struct WorkoutStatistics {
    
    /// 총 운동 횟수
    ///
    /// - Note: 사용자가 완료한 전체 운동 기록의 개수입니다.
    let totalWorkouts: Int
    
    /// 총 세션 수
    ///
    /// - Note: 사용자가 수행한 전체 운동 세션의 개수입니다.
    let totalSessions: Int
    
    /// 총 운동 시간 (초)
    ///
    /// - Note: 모든 운동 기록의 실제 운동 시간을 합산한 값입니다.
    let totalWorkoutTime: Int
    
    /// 총 볼륨 (무게 × 반복횟수의 합)
    ///
    /// - Note: 모든 운동의 볼륨을 합산하여 운동 강도를 나타냅니다.
    let totalVolume: Double
    
    /// 평균 운동 시간 (초)
    ///
    /// - Note: 총 운동 시간을 총 운동 횟수로 나눈 평균값입니다.
    let averageWorkoutDuration: Int
    
    /// 가장 많이 사용된 루틴 이름
    ///
    /// - Note: 사용자가 가장 자주 수행한 운동 루틴의 이름입니다.
    let mostUsedRoutine: String?
}

// MARK: - Computed Properties
extension WorkoutStatistics {
    
    /// 총 운동 시간을 시:분:초 형태로 반환합니다.
    var formattedTotalWorkoutTime: String {
        return formatTime(totalWorkoutTime)
    }
    
    /// 평균 운동 시간을 시:분:초 형태로 반환합니다.
    var formattedAverageWorkoutDuration: String {
        return formatTime(averageWorkoutDuration)
    }
    
    /// 운동 효율성을 계산합니다 (세션 대비 운동 비율).
    var workoutEfficiency: Double {
        guard totalSessions > 0 else { return 0.0 }
        return Double(totalWorkouts) / Double(totalSessions)
    }
    
    /// 평균 세션당 볼륨을 계산합니다.
    var averageVolumePerSession: Double {
        guard totalSessions > 0 else { return 0.0 }
        return totalVolume / Double(totalSessions)
    }
    
    /// 초 단위 시간을 시:분:초 형식으로 변환합니다.
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
}

// MARK: - Empty State
extension WorkoutStatistics {
    
    /// 빈 통계 객체를 생성합니다.
    static var empty: WorkoutStatistics {
        return WorkoutStatistics(
            totalWorkouts: 0,
            totalSessions: 0,
            totalWorkoutTime: 0,
            totalVolume: 0.0,
            averageWorkoutDuration: 0,
            mostUsedRoutine: nil
        )
    }
}
