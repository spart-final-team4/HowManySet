//
//  SaveRecordUseCaseProtocol.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import Foundation

/// 운동 기록을 저장하는 유스케이스의 프로토콜입니다.
///
/// 특정 사용자의 운동 기록을 저장하는 기능을 정의합니다.
protocol SaveRecordUseCaseProtocol {
    
    /// 주어진 사용자 ID에 해당하는 운동 기록을 저장합니다.
    ///
    /// - Parameters:
    ///   - uid: 운동 기록을 저장할 사용자의 고유 식별자
    ///   - item: 저장할 `WorkoutRecord` 객체
    func execute(uid: String, item: WorkoutRecord)
}

extension SaveRecordUseCaseProtocol {
    func execute(uid: String = "", item: WorkoutRecord) {
        execute(uid: uid, item: item)
    }
}
