//
//  User.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation

/// 사용자 온보딩 상태를 나타내는 열거형
public enum UserStatus {
    /// 닉네임 설정이 필요한 상태
    case needsNickname
    /// 온보딩 진행이 필요한 상태 (닉네임은 설정 완료)
    case needsOnboarding
    /// 모든 설정이 완료된 상태
    case complete
}


/// 앱 전체에서 사용되는 통합된 사용자 도메인 모델
///
/// Firebase Auth와 Firestore에서 관리되는 사용자 정보를 캡슐화하며,
/// 다양한 로그인 제공자(카카오, 구글, Apple, 익명)를 지원합니다.
public struct User {
    /// Firebase Auth에서 제공하는 고유 사용자 식별자
    public let uid: String
    
    /// 사용자 닉네임
    public let name: String
    
    /// 로그인 제공자 식별자
    /// - "kakao": 카카오 로그인
    /// - "google": 구글 로그인
    /// - "apple": Apple 로그인
    /// - "anonymous": 익명 로그인
    public let provider: String
    
    /// 사용자 이메일 주소 (선택적)
    public let email: String?
    
    /// 닉네임 설정 완료 여부
    public let hasSetNickname: Bool
    
    /// 온보딩 프로세스 완료 여부
    public let hasCompletedOnboarding: Bool

    /// User 인스턴스를 생성합니다
    /// - Parameters:
    ///   - uid: Firebase Auth 사용자 ID
    ///   - name: 사용자 닉네임
    ///   - provider: 로그인 제공자 식별자
    ///   - email: 사용자 이메일 (선택적)
    ///   - hasSetNickname: 닉네임 설정 완료 여부 (기본값: false)
    ///   - hasCompletedOnboarding: 온보딩 완료 여부 (기본값: false)
    public init(
        uid: String,
        name: String,
        provider: String,
        email: String? = nil,
        hasSetNickname: Bool = false,
        hasCompletedOnboarding: Bool = false
    ) {
        self.uid = uid
        self.name = name
        self.provider = provider
        self.email = email
        self.hasSetNickname = hasSetNickname
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}
