//
//  FSUserSettingRepositoryImpl.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation
import RxSwift

/// Firestore 기반 사용자 설정 저장소 구현체입니다.
/// 기존 UserSettingRepository 프로토콜을 구현하여 일관된 인터페이스를 제공합니다.
final class FSUserSettingRepositoryImpl: UserSettingRepository {
    
    private let firestoreService: FirestoreServiceProtocol
    
    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }
    
    /// 사용자 설정을 Firestore에서 불러옵니다.
    func fetchUserSetting(uid: String) -> Single<UserSetting> {
        return Single.create { [weak self] observer in
            Task {
                do {
                    // TODO: FSUserSetting 모델 생성 후 구현
                    // let fsSettings = try await self?.firestoreService.read(userId: uid, type: .userSetting)
                    
                    // 임시 기본값 반환
                    let defaultSetting = UserSetting(
                        pushNotificationEnabled: false,
                        unit: "metric",
                        darkmode: true,
                        locale: "ko_KR"
                    )
                    observer(.success(defaultSetting))
                } catch {
                    observer(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
    
    /// 사용자 설정을 Firestore에 저장합니다.
    func saveUserSetting(uid: String, settings: UserSetting) {
        Task {
            do {
                // TODO: FSUserSetting 모델 생성 후 구현
                // let fsSettings = FSUserSetting(dto: settings, userId: uid)
                // _ = try await firestoreService.create(item: fsSettings, type: .userSetting)
                print("Firestore 설정 저장 - 구현 필요")
            } catch {
                print("Firestore 설정 저장 실패: \(error)")
            }
        }
    }
}
