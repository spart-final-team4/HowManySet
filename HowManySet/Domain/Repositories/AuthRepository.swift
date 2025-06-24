//
//  AuthRepositoryProtocol.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import RxSwift

/// 인증 관련 데이터 처리를 정의하는 프로토콜
///
/// 다양한 소셜 로그인 제공자(카카오, 구글, Apple, 익명)를 지원하며,
/// Firebase Auth와 Firestore를 통한 사용자 인증 및 데이터 관리 기능을 추상화합니다.
public protocol AuthRepositoryProtocol {
    
    /// 카카오 계정으로 로그인을 수행합니다
    /// - Returns: 로그인된 사용자 정보를 방출하는 Observable
    func signInWithKakao() -> Observable<User>
    
    /// 구글 계정으로 로그인을 수행합니다
    /// - Returns: 로그인된 사용자 정보를 방출하는 Observable
    func signInWithGoogle() -> Observable<User>
    
    /// Apple ID로 로그인을 수행합니다
    /// - Parameters:
    ///   - token: Apple ID 토큰
    ///   - nonce: 보안을 위한 nonce 값
    /// - Returns: 로그인된 사용자 정보를 방출하는 Observable
    func signInWithApple(token: String, nonce: String) -> Observable<User>
    
    /// 익명 로그인을 수행합니다
    /// - Returns: 익명 사용자 정보를 방출하는 Observable
    func signInAnonymously() -> Observable<User>
    
    /// 현재 사용자를 로그아웃시킵니다
    /// - Returns: 로그아웃 완료를 알리는 Observable
    func signOut() -> Observable<Void>
    
    /// 현재 사용자의 계정을 완전히 삭제합니다
    ///
    /// 소셜 로그인 연결 해제, Firestore 데이터 삭제, Firebase Auth 계정 삭제를 포함합니다.
    /// - Returns: 계정 삭제 완료를 알리는 Observable
    func deleteAccount() -> Observable<Void>
    
    /// 특정 사용자의 정보를 Firestore에서 조회합니다
    /// - Parameter uid: 조회할 사용자의 고유 식별자
    /// - Returns: 사용자 정보를 방출하는 Observable (사용자가 없으면 nil)
    func fetchUserInfo(uid: String) -> Observable<User?>
    
    /// 사용자의 닉네임을 업데이트합니다
    /// - Parameters:
    ///   - uid: 사용자 고유 식별자
    ///   - nickname: 새로운 닉네임
    /// - Returns: 업데이트 완료를 알리는 Observable
    func updateUserNickname(uid: String, nickname: String) -> Observable<Void>
    
    /// 사용자의 온보딩 완료 상태를 업데이트합니다
    /// - Parameters:
    ///   - uid: 사용자 고유 식별자
    ///   - completed: 온보딩 완료 여부
    /// - Returns: 업데이트 완료를 알리는 Observable
    func updateOnboardingStatus(uid: String, completed: Bool) -> Observable<Void>
    
    /// 사용자의 온보딩 상태를 초기화합니다
    /// - Parameter uid: 사용자 고유 식별자
    /// - Returns: 초기화 완료를 알리는 Observable
    func resetUserOnboardingStatus(uid: String) -> Observable<Void>
    
    /// 현재 로그인된 사용자의 정보를 가져옵니다
    /// - Returns: 현재 사용자 정보를 방출하는 Observable (로그인되지 않은 경우 nil)
    func getCurrentUser() -> Observable<User?>
    
    /// 소셜 로그인 제공자별 고유 식별자로 기존 사용자를 찾습니다
    /// - Parameters:
    ///   - kakaoId: 카카오 사용자 고유 식별자 (선택적)
    ///   - googleId: 구글 사용자 고유 식별자 (선택적)
    ///   - appleId: Apple 사용자 고유 식별자 (선택적)
    /// - Returns: 기존 사용자 정보를 방출하는 Observable (없으면 nil)
    func findExistingUser(kakaoId: Int64?, googleId: String?, appleId: String?) -> Observable<User?>
}
