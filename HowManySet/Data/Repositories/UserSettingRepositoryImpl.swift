//
//  UserSettingRepositoryImpl.swift
//  HowManySet
//
//  Created by 정근호 on 6/4/25.
//

import Foundation
import RxSwift

// 대략적으로 세팅
final class UserSettingRepositoryImpl: UserSettingRepository {
    
    func fetchUserSetting(uid: String) -> RxSwift.Single<UserSetting> {
        <#code#>
    }
    
    func saveUserSetting(uid: String, settings: UserSetting) {
        <#code#>
    }
    
}
