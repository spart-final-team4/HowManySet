//
//  FirebaseAuthServiceProtocol.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation

/// Firebase Auth 서비스를 정의하는 프로토콜
/// - Firebase Auth의 기본 기능들을 추상화
public protocol FirebaseAuthServiceProtocol {
    /// 익명 로그인 처리
    /// - Parameter completion: 로그인 결과 콜백
    func signInAnonymously(completion: @escaping (Result<User, Error>) -> Void)
    
    /// 현재 로그인된 사용자 정보 가져오기
    /// - Returns: 현재 사용자 (없으면 nil)
    func fetchCurrentUser() -> User?
    
    /// 로그아웃 처리
    /// - Returns: 로그아웃 결과
    func signOut() -> Result<Void, Error>
    
    /// 계정 삭제 처리
    /// - Parameter completion: 삭제 결과 콜백
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void)
}
