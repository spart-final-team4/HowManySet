//
//  AuthUseCaseProtocol.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import RxSwift

/// 인증 관련 비즈니스 로직을 정의하는 프로토콜
///
/// 다양한 소셜 로그인 제공자를 지원하며, 사용자 인증과 온보딩 프로세스의
/// 비즈니스 규칙을 추상화합니다. Repository 계층과 Presentation 계층 사이의
/// 중간 역할을 담당합니다.
public protocol AuthUseCaseProtocol {
    
    /// 카카오 계정으로 로그인을 수행합니다
    ///
    /// 로그인 성공 시 UserDefaults에 백업 데이터를 저장하며,
    /// 기존 온보딩 상태를 유지합니다.
    /// - Returns: 로그인된 사용자 정보를 방출하는 Observable
    func loginWithKakao() -> Observable<User>
    
    /// 구글 계정으로 로그인을 수행합니다
    ///
    /// 로그인 성공 시 UserDefaults에 백업 데이터를 저장하며,
    /// 기존 온보딩 상태를 유지합니다.
    /// - Returns: 로그인된 사용자 정보를 방출하는 Observable
    func loginWithGoogle() -> Observable<User>
    
    /// Apple ID로 로그인을 수행합니다
    ///
    /// 로그인 성공 시 UserDefaults에 백업 데이터를 저장하며,
    /// 기존 온보딩 상태를 유지합니다.
    /// - Parameters:
    ///   - token: Apple ID 토큰
    ///   - nonce: 보안을 위한 nonce 값
    /// - Returns: 로그인된 사용자 정보를 방출하는 Observable
    func loginWithApple(token: String, nonce: String) -> Observable<User>
    
    /// 익명 로그인을 수행합니다
    ///
    /// 익명 사용자의 경우 모든 데이터를 로컬(UserDefaults)에만 저장합니다.
    /// - Returns: 익명 사용자 정보를 방출하는 Observable
    func loginAnonymously() -> Observable<User>
    
    /// 현재 사용자를 로그아웃시킵니다
    ///
    /// Firestore의 온보딩 상태는 유지하고 UserDefaults만 초기화합니다.
    /// 재로그인 시 기존 온보딩 상태를 복원할 수 있습니다.
    /// - Returns: 로그아웃 완료를 알리는 Observable
    func logout() -> Observable<Void>
    
    /// 현재 사용자의 계정을 완전히 삭제합니다
    ///
    /// 소셜 로그인 연결 해제, Firestore 데이터 삭제, 로컬 데이터 초기화를
    /// 모두 수행합니다.
    /// - Returns: 계정 삭제 완료를 알리는 Observable
    func deleteAccount() -> Observable<Void>
    
    /// 사용자의 온보딩 상태를 조회합니다
    ///
    /// 익명 사용자는 로컬 상태를, 일반 사용자는 Firestore 상태를 확인하여
    /// 온보딩 필요 여부를 판단합니다.
    /// - Parameter uid: 사용자 고유 식별자
    /// - Returns: 사용자 온보딩 상태를 방출하는 Observable
    func getUserStatus(uid: String) -> Observable<UserStatus>
    
    /// 사용자의 닉네임 설정을 완료합니다
    ///
    /// 닉네임 유효성 검사를 수행하며, 익명 사용자는 로컬에,
    /// 일반 사용자는 Firestore에 저장합니다.
    /// - Parameters:
    ///   - uid: 사용자 고유 식별자
    ///   - nickname: 설정할 닉네임 (한글/영문/숫자 2~8자)
    /// - Returns: 닉네임 설정 완료를 알리는 Observable
    func completeNicknameSetting(uid: String, nickname: String) -> Observable<Void>
    
    /// 사용자의 온보딩 프로세스를 완료합니다
    ///
    /// 익명 사용자는 로컬에, 일반 사용자는 Firestore에 완료 상태를 저장합니다.
    /// - Parameter uid: 사용자 고유 식별자
    /// - Returns: 온보딩 완료를 알리는 Observable
    func completeOnboarding(uid: String) -> Observable<Void>
    
    /// 사용자의 온보딩 상태를 초기화합니다
    ///
    /// 개발 및 테스트 목적으로 사용되며, 온보딩을 처음부터 다시 진행할 수 있도록 합니다.
    /// - Parameter uid: 사용자 고유 식별자
    /// - Returns: 온보딩 상태 초기화 완료를 알리는 Observable
    func resetUserOnboardingStatus(uid: String) -> Observable<Void>
}
