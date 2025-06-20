//
//  AuthUseCase.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import RxSwift

/// 인증 관련 비즈니스 로직을 처리하는 UseCase 구현체
/// - Repository를 통해 데이터를 처리하고 비즈니스 규칙을 적용
public final class AuthUseCase: AuthUseCaseProtocol {
    /// 인증 데이터 처리를 담당하는 Repository
    private let repository: AuthRepositoryProtocol

    /// AuthUseCase 생성자
    /// - Parameter repository: 인증 데이터 처리 Repository
    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    /// 카카오 로그인 비즈니스 로직
    /// - Returns: 로그인된 사용자 정보 Observable
    public func loginWithKakao() -> Observable<User> {
        return repository.signInWithKakao()
            .do(onNext: { user in
                print("카카오 로그인 성공: \(user.name)")
            })
    }

    /// 구글 로그인 비즈니스 로직
    /// - Returns: 로그인된 사용자 정보 Observable
    public func loginWithGoogle() -> Observable<User> {
        return repository.signInWithGoogle()
            .do(onNext: { user in
                print("구글 로그인 성공: \(user.name)")
            })
    }

    /// Apple 로그인 비즈니스 로직
    /// - Parameters:
    ///   - token: Apple ID 토큰
    ///   - nonce: 보안을 위한 nonce 값
    /// - Returns: 로그인된 사용자 정보 Observable
    public func loginWithApple(token: String, nonce: String) -> Observable<User> {
        return repository.signInWithApple(token: token, nonce: nonce)
            .do(onNext: { user in
                print("Apple 로그인 성공: \(user.name)")
            })
    }

    /// 익명 로그인 비즈니스 로직
    /// - Returns: 로그인된 사용자 정보 Observable
    public func loginAnonymously() -> Observable<User> {
        return repository.signInAnonymously()
            .do(onNext: { user in
                print("익명 로그인 성공: \(user.name)")
            })
    }
    
    /// 로그아웃 비즈니스 로직
    /// - Returns: 로그아웃 결과 Observable
    public func logout() -> Observable<Void> {
        return repository.signOut()
            .do(onNext: { _ in
                print("로그아웃 성공")
                // 필요시 추가 비즈니스 로직 (캐시 삭제 등)
            })
    }
    
    /// 계정 삭제 비즈니스 로직
    /// - Returns: 계정 삭제 결과 Observable
    public func deleteAccount() -> Observable<Void> {
        return repository.deleteAccount()
            .do(onNext: { _ in
                print("계정 삭제 성공")
                // 필요시 추가 비즈니스 로직 (로컬 데이터 삭제 등)
            })
    }
}
