//
//  UserSetting.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import Foundation

/// 사용자 설정 정보를 저장하는 구조체입니다.
///
/// 이 구조체는 푸시 알림, 단위 시스템, 다크 모드, 로케일 등 사용자 개인화 설정을 포함합니다.
struct UserSetting {
    
    /// 푸시 알림 활성화 여부입니다.
    ///
    /// `true`이면 푸시 알림이 활성화되어 있고, `false`이면 비활성화되어 있습니다.
    var pushNotificationEnabled: Bool
    
    /// 사용자가 선택한 단위입니다.
    ///
    /// 예: `"metric"` 또는 `"imperial"` 등
    var unit: String
    
    /// 다크 모드 사용 여부입니다.
    ///
    /// `true`이면 다크 모드가 활성화되어 있고, `false`이면 라이트 모드를 사용합니다.
    var darkmode: Bool
    
    /// 사용자의 로케일 설정입니다.
    ///
    /// 예: `"en_US"`, `"ko_KR"` 등
    var locale: String
}
