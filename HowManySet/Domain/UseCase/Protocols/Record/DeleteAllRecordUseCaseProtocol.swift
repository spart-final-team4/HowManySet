//
//  DeleteAllRecordUseCaseProtocol.swift
//  HowManySet
//
//  Created by MJ Dev on 6/9/25.
//

import Foundation

/// 사용자의 모든 운동 기록을 삭제하는 유스케이스를 정의한 프로토콜입니다.
/// 기록 전체 삭제와 관련된 비즈니스 로직을 담당합니다.
protocol DeleteAllRecordUseCaseProtocol {
    
    /// 사용자의 모든 운동 기록을 삭제합니다.
    func execute(uid: String)
}

extension DeleteAllRecordUseCaseProtocol {
    func execute(uid: String = "") {
        execute(uid: uid)
    }
}
