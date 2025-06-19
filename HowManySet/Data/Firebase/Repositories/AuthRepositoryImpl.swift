//
//  AuthRepositoryImpl.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation

final class AuthRepositoryImpl: AuthRepository {
    private let authService: FirebaseAuthServiceProtocol

    init(authService: FirebaseAuthServiceProtocol) {
        self.authService = authService
    }

    func signInAnonymously(completion: @escaping (Result<User, Error>) -> Void) {
        authService.signInAnonymously(completion: completion)
    }

    func fetchCurrentUser() -> User? {
        return authService.fetchCurrentUser()
    }

    func signOut() -> Result<Void, Error> {
        return authService.signOut()
    }

    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        authService.deleteAccount(completion: completion)
    }
}
