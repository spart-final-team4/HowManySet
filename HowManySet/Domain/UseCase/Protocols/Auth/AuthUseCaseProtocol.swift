//
//  AuthUseCaseProtocol.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

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
}
