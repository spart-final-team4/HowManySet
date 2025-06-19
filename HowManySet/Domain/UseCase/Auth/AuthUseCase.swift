//
//  AuthUseCase.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation

final class AuthUseCase: AuthUseCaseProtocol {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func signInAnonymously(completion: @escaping (Result<User, Error>) -> Void) {
        repository.signInAnonymously(completion: completion)
    }

    func fetchCurrentUser() -> User? {
        return repository.fetchCurrentUser()
    }

    func signOut() -> Result<Void, Error> {
        return repository.signOut()
    }

    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        repository.deleteAccount(completion: completion)
    }
}
