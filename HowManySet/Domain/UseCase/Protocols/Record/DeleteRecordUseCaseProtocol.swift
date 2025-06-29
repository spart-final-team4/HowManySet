//
//  DeleteRecordUseCaseProtocol.swift
//  HowManySet
//
//  Created by MJ Dev on 6/9/25.
//

import Foundation

/// 운동 기록을 삭제하는 유스케이스를 정의한 프로토콜입니다.
/// 비즈니스 로직 계층에서 특정 운동 기록을 삭제하는 책임을 가집니다.
protocol DeleteRecordUseCaseProtocol {
    
    /// 특정 운동 기록을 삭제합니다.
    /// - Parameters:
    ///   - item: 삭제할 운동 기록
    func execute(uid: String?, item: WorkoutRecord)
}
