//
//  FirebaseAuthService.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class FirebaseAuthService: FirebaseAuthServiceProtocol {
    private let db = Firestore.firestore()

    func signInAnonymously(completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                completion(.failure(error)); return
            }
            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "NoUser", code: -1))); return
            }
            self.setupDefaultFirestoreData(uid: user.uid)
            completion(.success(User(uid: user.uid, email: user.email)))
        }
    }

    func fetchCurrentUser() -> User? {
        guard let user = Auth.auth().currentUser else { return nil }
        return User(uid: user.uid, email: user.email)
    }

    func signOut() -> Result<Void, Error> {
        do {
            try Auth.auth().signOut()
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "NoUser", code: -1))); return
        }
        let uid = user.uid

        // Firestore defaults 컬렉션 전체 삭제
        let docRef = db.collection("defaults").document(uid)
        docRef.delete { error in
            if let error = error {
                completion(.failure(error)); return
            }
            user.delete { error in
                if let error = error {
                    completion(.failure(error)); return
                }
                completion(.success(()))
            }
        }
    }

    private func setupDefaultFirestoreData(uid: String) {
        let userRef = db.collection("defaults").document(uid)
        userRef.setData(["createdAt": FieldValue.serverTimestamp()], merge: true)
        userRef.collection("Routine").addDocument(data: ["title": "기본루틴", "createdAt": FieldValue.serverTimestamp()])
        userRef.collection("Record").addDocument(data: ["note": "첫기록", "createdAt": FieldValue.serverTimestamp()])
        userRef.collection("UserSetting").document("default").setData(["unit": "kg"])
    }
}
