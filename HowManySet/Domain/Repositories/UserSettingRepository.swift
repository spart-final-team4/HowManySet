//
//  UserSettingRepository.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import Foundation
import RxSwift

/// 사용자 설정 정보의 저장 및 조회 기능을 제공하는 리포지토리 프로토콜입니다.
///
/// 로컬 또는 원격 데이터 소스와의 인터페이스를 정의합니다.
protocol UserSettingRepository {
    
    /// 주어진 사용자 ID에 해당하는 사용자 설정 정보를 비동기적으로 조회합니다.
    ///
    /// - Parameter uid: 설정 정보를 조회할 사용자의 고유 식별자
    /// - Returns: `Single`로 감싸진 `UserSetting` 객체, 조회 성공 시 설정 정보를 방출하고 실패 시 에러를 방출합니다.
    func fetchUserSetting(uid: String) -> Single<UserSetting>
    
    /// 주어진 사용자 ID에 해당하는 사용자 설정 정보를 저장합니다.
    ///
    /// - Parameters:
    ///   - uid: 설정 정보를 저장할 사용자의 고유 식별자
    ///   - settings: 저장할 `UserSetting` 객체
    func saveUserSetting(uid: String, settings: UserSetting)
}

// MARK: Realm Repository
extension UserSettingRepository {
    func fetchUserSetting() -> Single<UserSetting> {
        return fetchUserSetting(uid: "")
    }
    
    func saveUserSetting(settings: UserSetting) {
        saveUserSetting(uid: "", settings: settings)
    }
}
