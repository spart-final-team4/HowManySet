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
    
    func fetchUserSetting() -> Single<UserSetting> {
        return Single<UserSetting>.just(UserSetting(pushNotificationEnabled: false, unit: "metric", darkmode: true, locale: "ko_KR"))
    }
    
    func saveUserSetting(settings: UserSetting) {

    }
    
}
