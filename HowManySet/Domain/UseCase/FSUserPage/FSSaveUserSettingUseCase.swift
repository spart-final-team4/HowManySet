//
//  FSSaveUserSettingUseCase.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation

/// Firestore 기반 사용자 설정 정보를 저장하는 유스케이스 구현체입니다.
/// FSUserSettingRepository를 통해 특정 사용자의 설정 정보를 저장하는 기능을 제공합니다.
final class FSSaveUserSettingUseCase: SaveUserSettingUseCaseProtocol {
    
    /// Firestore 사용자 설정 정보를 관리하는 리포지토리 객체
    private let repository: UserSettingRepository
    
    /// 초기화 메서드
    /// - Parameter repository: Firestore 사용자 설정 저장소 프로토콜을 구현한 인스턴스
    init(repository: UserSettingRepository) {
        self.repository = repository
    }
    
    /// 주어진 사용자 ID에 해당하는 설정 정보를 Firestore에 저장합니다.
    /// - Parameters:
    ///   - uid: 설정 정보를 저장할 사용자의 고유 식별자
    ///   - settings: 저장할 `UserSetting` 객체
    func execute(uid: String, settings: UserSetting) {
        repository.saveUserSetting(uid: uid, settings: settings)
    }
}
