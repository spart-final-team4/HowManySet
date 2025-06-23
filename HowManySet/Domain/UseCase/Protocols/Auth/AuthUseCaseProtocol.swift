//
//  AuthUseCaseProtocol.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation
import RxSwift

/// 인증 관련 비즈니스 로직을 정의하는 프로토콜
/// - 다양한 로그인 방식의 비즈니스 로직을 추상화
public protocol AuthUseCaseProtocol {
    /// 카카오 로그인 비즈니스 로직
    /// - Returns: 로그인된 사용자 정보 Observable
    func loginWithKakao() -> Observable<User>
    
    /// 구글 로그인 비즈니스 로직
    /// - Returns: 로그인된 사용자 정보 Observable
    func loginWithGoogle() -> Observable<User>
    
    /// Apple 로그인 비즈니스 로직
    /// - Parameters:
    ///   - token: Apple ID 토큰
    ///   - nonce: 보안을 위한 nonce 값
    /// - Returns: 로그인된 사용자 정보 Observable
    func loginWithApple(token: String, nonce: String) -> Observable<User>
    
    /// 익명 로그인 비즈니스 로직
    /// - Returns: 로그인된 사용자 정보 Observable
    func loginAnonymously() -> Observable<User>
    
    /// 로그아웃 비즈니스 로직
    /// - Returns: 로그아웃 결과 Observable
    func logout() -> Observable<Void>
    
    /// 계정 삭제 비즈니스 로직
    /// - Returns: 계정 삭제 결과 Observable
    func deleteAccount() -> Observable<Void>
    
    /// 사용자 상태 조회 비즈니스 로직
    /// - Parameter uid: 사용자 ID
    /// - Returns: 사용자 상태 Observable
    func getUserStatus(uid: String) -> Observable<UserStatus>
    
    /// 닉네임 설정 완료 비즈니스 로직
    /// - Parameters:
    ///   - uid: 사용자 ID
    ///   - nickname: 설정할 닉네임
    /// - Returns: 완료 결과 Observable
    func completeNicknameSetting(uid: String, nickname: String) -> Observable<Void>
    
    /// 온보딩 완료 비즈니스 로직
    /// - Parameter uid: 사용자 ID
    /// - Returns: 완료 결과 Observable
    func completeOnboarding(uid: String) -> Observable<Void>
}
