//
//  SaveUserSettingUseCaseProtocol.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import Foundation

/// 사용자 설정 정보를 저장하는 유스케이스 프로토콜입니다.
///
/// 특정 사용자의 설정 정보를 저장하는 기능을 정의합니다.
protocol SaveUserSettingUseCaseProtocol {
    
    /// 주어진 사용자 ID에 해당하는 사용자 설정 정보를 저장합니다.
    ///
    /// - Parameters:
    ///   - settings: 저장할 `UserSetting` 객체
    func execute(uid: String, settings: UserSetting)
}

extension SaveUserSettingUseCaseProtocol {
    func execute(uid: String = "", settings: UserSetting) {
        execute(uid: uid, settings: settings)
    }
}
