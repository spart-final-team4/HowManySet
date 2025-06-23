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
    let hasSetNickname: Bool
    let hasCompletedOnboarding: Bool

    init(uid: String, name: String, provider: String, email: String? = nil, hasSetNickname: Bool = false, hasCompletedOnboarding: Bool = false) {
        self.uid = uid
        self.name = name
        self.provider = provider
        self.email = email
        self.hasSetNickname = hasSetNickname
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    func toEntity() -> User {
        return User(uid: uid, name: name, provider: provider, email: email, hasSetNickname: hasSetNickname, hasCompletedOnboarding: hasCompletedOnboarding)
    }

    static func from(uid: String, data: [String: Any]) -> UserDTO? {
        guard let name = data["name"] as? String,
              let provider = data["provider"] as? String else {
            return nil
        }
        let email = data["email"] as? String
        let hasSetNickname = data["hasSetNickname"] as? Bool ?? false
        let hasCompletedOnboarding = data["hasCompletedOnboarding"] as? Bool ?? false
        return UserDTO(uid: uid, name: name, provider: provider, email: email, hasSetNickname: hasSetNickname, hasCompletedOnboarding: hasCompletedOnboarding)
    }

    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "uid": uid,
            "name": name,
            "provider": provider,
            "hasSetNickname": hasSetNickname,
            "hasCompletedOnboarding": hasCompletedOnboarding,
            "createdAt": FieldValue.serverTimestamp()
        ]
        if let email = email {
            data["email"] = email
        }
        return data
    }
}
