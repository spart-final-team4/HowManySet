//
//  FirebaseAuthServiceProtocol.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation

protocol FirebaseAuthServiceProtocol {
    func signInAnonymously(completion: @escaping (Result<User, Error>) -> Void)
    func fetchCurrentUser() -> User?
    func signOut() -> Result<Void, Error>
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void)
}
