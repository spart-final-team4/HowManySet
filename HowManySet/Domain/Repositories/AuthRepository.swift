//
//  AuthRepository.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import RxSwift

public protocol AuthRepositoryProtocol {
    func signInWithKakao() -> Observable<User>
    func signInWithGoogle() -> Observable<User>
    func signInWithApple(token: String, nonce: String) -> Observable<User>
    func signInAnonymously() -> Observable<User>
    func signOut() -> Observable<Void>
    func deleteAccount() -> Observable<Void>
}
