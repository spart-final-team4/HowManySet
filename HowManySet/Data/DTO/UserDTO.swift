//
//  UserDTO.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation

/// FirebaseAuth User와 Firestore User를 매핑하기 위한 DTO
struct UserDTO: Codable {
    let uid: String
    let email: String?
    let displayName: String?
    let provider: String?
    let createdAt: Date?

    func toDomain() -> User {
        return User(uid: uid, email: email)
    }
}
