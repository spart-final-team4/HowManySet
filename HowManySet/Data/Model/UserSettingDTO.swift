//
//  UserSettingDTO.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import Foundation

/// 사용자 설정 정보를 전송하거나 저장할 때 사용하는 데이터 전송 객체(Data Transfer Object)입니다.
///
/// 주로 네트워크 통신, 로컬 저장소 등 외부 데이터와의 교환 시 사용됩니다.
struct UserSettingDTO {
    
    /// 푸시 알림 활성화 여부입니다.
    let pushNotificationEnabled: Bool
    
    /// 단위 설정입니다. 예: `"metric"`, `"imperial"` 등
    let unit: String
    
    /// 다크 모드 활성화 여부입니다.
    let darkmode: Bool
    
    /// 로케일 설정입니다. 예: `"ko_KR"`, `"en_US"` 등
    let locale: String
}

extension UserSettingDTO {
    
    /// DTO를 도메인 모델인 `UserSetting` 객체로 변환합니다.
    ///
    /// - Returns: `UserSetting` 타입의 도메인 모델 인스턴스
    func toEntity() -> UserSetting {
        return UserSetting(pushNotificationEnabled: self.pushNotificationEnabled,
                           unit: self.unit,
                           darkmode: self.darkmode,
                           locale: self.locale)
    }
}
