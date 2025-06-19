//
//  FirebaseAuthService.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Firebase Auth 서비스 구현체
/// - Firebase Auth의 기본 기능들을 구현
public final class FirebaseAuthService: FirebaseAuthServiceProtocol {
    /// Firestore 데이터베이스 인스턴스
    private let db = Firestore.firestore()

    public init() {}

    /// 익명 로그인 처리
    /// - Parameter completion: 로그인 결과 콜백
    public func signInAnonymously(completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "NoUser", code: -1)))
                return
            }
            self.setupDefaultFirestoreData(uid: user.uid)
            let userModel = User(
                uid: user.uid,
                name: "익명 사용자",
                provider: "anonymous",
                email: user.email
            )
            completion(.success(userModel))
        }
    }

    /// 현재 로그인된 사용자 정보 가져오기
    /// - Returns: 현재 사용자 (없으면 nil)
    public func fetchCurrentUser() -> User? {
        guard let user = Auth.auth().currentUser else { return nil }
        return User(
            uid: user.uid,
            name: user.displayName ?? "사용자",
            provider: "firebase",
            email: user.email
        )
    }

    /// 로그아웃 처리
    /// - Returns: 로그아웃 결과
    public func signOut() -> Result<Void, Error> {
        do {
            try Auth.auth().signOut()
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    /// 계정 삭제 처리
    /// - Parameter completion: 삭제 결과 콜백
    public func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "NoUser", code: -1)))
            return
        }
        let uid = user.uid

        // 🔥 Firestore 데이터 먼저 삭제
        let userRef = db.collection("users").document(uid)
        let defaultsRef = db.collection("defaults").document(uid)
        
        // 병렬로 데이터 삭제
        let group = DispatchGroup()
        var deletionError: Error?
        
        group.enter()
        userRef.delete { error in
            if let error = error {
                deletionError = error
            }
            group.leave()
        }
        
        group.enter()
        defaultsRef.delete { error in
            if let error = error {
                deletionError = error
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if let error = deletionError {
                completion(.failure(error))
                return
            }
            
            // 🔥 Firebase Auth 계정 삭제
            user.delete { error in
                if let error = error {
                    print("Firebase Auth 계정 삭제 실패: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                print("🔥 Firebase Auth 계정 삭제 성공")
                completion(.success(()))
            }
        }
    }


    /// 기본 Firestore 데이터 설정
    /// - Parameter uid: 사용자 ID
    private func setupDefaultFirestoreData(uid: String) {
        let userRef = db.collection("defaults").document(uid)
        userRef.setData(["createdAt": FieldValue.serverTimestamp()], merge: true)
        userRef.collection("Routine").addDocument(data: ["title": "기본루틴", "createdAt": FieldValue.serverTimestamp()])
        userRef.collection("Record").addDocument(data: ["note": "첫기록", "createdAt": FieldValue.serverTimestamp()])
        userRef.collection("UserSetting").document("default").setData(["unit": "kg"])
    }
}
