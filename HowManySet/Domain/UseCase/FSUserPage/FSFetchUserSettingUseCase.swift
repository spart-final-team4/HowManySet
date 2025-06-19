//
//  FSFetchUserSettingUseCase.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation
import RxSwift

/// Firestore 기반 사용자 설정 정보를 조회하는 유스케이스 구현체입니다.
/// FSUserSettingRepository를 통해 특정 사용자의 설정 정보를 비동기적으로 가져오는 기능을 제공합니다.
final class FSFetchUserSettingUseCase: FetchUserSettingUseCaseProtocol {
    
    /// Firestore 사용자 설정 정보를 관리하는 리포지토리 객체
    private let repository: UserSettingRepository
    
    /// 초기화 메서드
    /// - Parameter repository: Firestore 사용자 설정 저장소 프로토콜을 구현한 인스턴스
    init(repository: UserSettingRepository) {
        self.repository = repository
    }
    
    /// 주어진 사용자 ID에 해당하는 설정 정보를 Firestore에서 비동기적으로 조회합니다.
    /// - Parameter uid: 설정 정보를 조회할 사용자의 고유 식별자
    /// - Returns: `Single`로 감싸진 `UserSetting` 객체, 조회 성공 시 설정 정보를 방출하고 실패 시 에러를 방출합니다.
    func execute(uid: String) -> Single<UserSetting> {
        return repository.fetchUserSetting(uid: uid)
    }
}
