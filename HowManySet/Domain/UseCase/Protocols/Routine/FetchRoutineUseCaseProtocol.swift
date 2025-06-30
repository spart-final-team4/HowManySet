//
//  FetchRoutineUseCaseProtocol.swift
//  HowManySet
//
//  Created by MJ Dev on 6/2/25.
//

import Foundation
import RxSwift

/// 운동 루틴을 가져오는 유스케이스 프로토콜입니다.
///
/// 특정 사용자의 운동 루틴 목록을 비동기적으로 조회하는 기능을 정의합니다.
protocol FetchRoutineUseCaseProtocol {
    
    /// 주어진 사용자 ID에 해당하는 운동 루틴 리스트를 비동기적으로 가져옵니다.
    ///
    /// - Returns: `Single`로 감싸진 `WorkoutRoutine` 배열, 조회 성공 시 배열을 방출하고 실패 시 에러를 방출합니다.
    func execute(uid: String?) -> Single<[WorkoutRoutine]>
}
