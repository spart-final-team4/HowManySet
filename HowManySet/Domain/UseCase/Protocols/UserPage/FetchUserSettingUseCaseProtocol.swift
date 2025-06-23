//
//  FetchUserSettingUseCaseProtocol.swift
//  HowManySet
//
//  Created by MJ Dev on 6/2/25.
//

import Foundation
import RxSwift

/// 사용자 설정 정보를 가져오는 유스케이스 프로토콜입니다.
///
/// 특정 사용자의 설정 정보를 비동기적으로 조회하는 기능을 정의합니다.
protocol FetchUserSettingUseCaseProtocol {
    
    /// 주어진 사용자 ID에 해당하는 사용자 설정 정보를 비동기적으로 가져옵니다.
    ///
    /// - Parameter uid: 설정 정보를 조회할 사용자의 고유 식별자
    /// - Returns: `Single`로 감싸진 `UserSetting` 객체, 조회 성공 시 설정 정보를 방출하고 실패 시 에러를 방출합니다.
    func execute(uid: String) -> Single<UserSetting>
}

extension FetchUserSettingUseCaseProtocol {
    func execute(uid: String = "") -> Single<UserSetting> {
        return execute(uid: uid)
    }
}
