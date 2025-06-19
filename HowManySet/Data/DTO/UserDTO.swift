//
//  UserDTO.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation
import FirebaseFirestore

struct UserDTO {
    let uid: String
    let name: String
    let provider: String
    let email: String?

    func toEntity() -> User {
        return User(uid: uid, name: name, provider: provider, email: email)
    }

    static func from(uid: String, data: [String: Any]) -> UserDTO? {
        guard let name = data["name"] as? String,
              let provider = data["provider"] as? String else {
            return nil
        }
        let email = data["email"] as? String  // 선택적 필드
        return UserDTO(uid: uid, name: name, provider: provider, email: email)
    }

    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "name": name,
            "provider": provider,
            "createdAt": FieldValue.serverTimestamp()
        ]
        if let email = email {
            data["email"] = email
        }
        return data
    }
}
