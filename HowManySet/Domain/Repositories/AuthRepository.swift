//
//  AuthRepository.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation

protocol AuthRepository {
    /// 익명 로그인
    func signInAnonymously(completion: @escaping (Result<User, Error>) -> Void)
    /// 현재 로그인된 사용자를 도메인 모델로 반환
    func fetchCurrentUser() -> User?
    /// 로그아웃 처리
    func signOut() -> Result<Void, Error>
    /// 회원탈퇴 (Authentication + Firestore 데이터 삭제)
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void)
}
