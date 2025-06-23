//
//  FirebaseAuthService.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import KakaoSDKUser
import GoogleSignIn

/// Firebase Auth 서비스 구현체
///
/// Firebase Auth의 기본 기능들을 구현하며, 계정 삭제 시 모든 소셜 로그인 연결 끊기를 포함한
/// 완전한 데이터 삭제를 보장합니다.
public final class FirebaseAuthService: FirebaseAuthServiceProtocol {
    /// Firestore 데이터베이스 인스턴스
    private let db = Firestore.firestore()

    public init() {}

    /// 커스텀 토큰으로 Firebase Auth 로그인을 수행합니다
    /// - Parameters:
    ///   - customToken: Firebase 커스텀 토큰
    ///   - completion: 로그인 결과를 반환하는 콜백
    public func signInWithCustomToken(_ customToken: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withCustomToken: customToken) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "NoUser", code: -1)))
                return
            }
            
            let userModel = User(
                uid: user.uid,
                name: user.displayName ?? "사용자",
                provider: "custom",
                email: user.email
            )
            completion(.success(userModel))
        }
    }

    /// 익명 로그인을 수행하고 기본 Firestore 데이터를 설정합니다
    /// - Parameter completion: 로그인 결과를 반환하는 콜백
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

    /// 현재 로그인된 사용자 정보를 가져옵니다
    /// - Returns: 현재 사용자 정보 또는 nil (로그인되지 않은 경우)
    public func fetchCurrentUser() -> User? {
        guard let user = Auth.auth().currentUser else { return nil }
        return User(
            uid: user.uid,
            name: user.displayName ?? "사용자",
            provider: "firebase",
            email: user.email
        )
    }

    /// Firebase Auth에서 로그아웃을 수행합니다
    /// - Returns: 로그아웃 성공 여부
    public func signOut() -> Result<Void, Error> {
        do {
            try Auth.auth().signOut()
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    /// 계정을 완전히 삭제합니다
    ///
    /// 모든 소셜 로그인 연결을 끊고, UserDefaults를 초기화하며,
    /// Firestore 데이터와 Firebase Auth 계정을 삭제합니다.
    /// - Parameter completion: 삭제 결과를 반환하는 콜백
    public func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "NoUser", code: -1)))
            return
        }
        let uid = user.uid

        print("🔥 계정 삭제 시작: \(uid)")
        
        unlinkAllSocialConnections { [weak self] unlinkResult in
            switch unlinkResult {
            case .success:
                print("🟢 모든 소셜 연결 끊기 성공")
            case .failure(let error):
                print("🔴 소셜 연결 끊기 실패: \(error)")
            }
            
            self?.clearAllUserDefaults()
            self?.deleteFirestoreData(uid: uid, completion: completion)
        }
    }

    /// 사용자의 로그인 제공자에 따라 적절한 소셜 로그인 연결을 끊습니다
    /// - Parameter completion: 연결 끊기 결과를 반환하는 콜백
    private func unlinkAllSocialConnections(completion: @escaping (Result<Void, Error>) -> Void) {
        let userProvider = UserDefaults.standard.string(forKey: "userProvider") ?? ""
        
        switch userProvider {
        case "kakao":
            unlinkKakaoConnection(completion: completion)
        case "google":
            unlinkGoogleConnection(completion: completion)
        case "apple":
            unlinkAppleConnection(completion: completion)
        case "anonymous":
            print("🟡 익명 사용자 - 소셜 연결 끊기 스킵")
            completion(.success(()))
        default:
            print("🟡 알 수 없는 제공자: \(userProvider) - 연결 끊기 스킵")
            completion(.success(()))
        }
    }

    /// 카카오 플랫폼과의 연결을 끊습니다
    /// - Parameter completion: 연결 끊기 결과를 반환하는 콜백
    private func unlinkKakaoConnection(completion: @escaping (Result<Void, Error>) -> Void) {
        print("🟢 카카오 연결 끊기 시작")
        
        UserApi.shared.unlink { error in
            if let error = error {
                print("🔴 카카오 연결 끊기 실패: \(error)")
                completion(.failure(error))
            } else {
                print("🟢 카카오 연결 끊기 성공 - 앱과 카카오 간 연결 완전 해제")
                completion(.success(()))
            }
        }
    }

    /// 구글 플랫폼과의 연결을 끊습니다
    /// - Parameter completion: 연결 끊기 결과를 반환하는 콜백
    private func unlinkGoogleConnection(completion: @escaping (Result<Void, Error>) -> Void) {
        print("🟢 구글 연결 끊기 시작")
        
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "NoUser", code: -1)))
            return
        }
        
        user.unlink(fromProvider: "google.com") { authResult, error in
            if let error = error {
                print("🔴 구글 연결 끊기 실패: \(error)")
                completion(.failure(error))
            } else {
                print("🟢 구글 연결 끊기 성공")
                GIDSignIn.sharedInstance.signOut()
                completion(.success(()))
            }
        }
    }

    /// Apple 플랫폼과의 연결을 끊습니다
    /// - Parameter completion: 연결 끊기 결과를 반환하는 콜백
    private func unlinkAppleConnection(completion: @escaping (Result<Void, Error>) -> Void) {
        print("🟢 Apple 연결 끊기 시작")
        
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "NoUser", code: -1)))
            return
        }
        
        user.unlink(fromProvider: "apple.com") { authResult, error in
            if let error = error {
                print("🔴 Apple 연결 끊기 실패: \(error)")
                completion(.failure(error))
            } else {
                print("🟢 Apple 연결 끊기 성공")
                completion(.success(()))
            }
        }
    }

    /// 사용자 관련 모든 UserDefaults 데이터를 초기화합니다
    private func clearAllUserDefaults() {
        print("🟢 UserDefaults 완전 초기화 시작")
        
        let keysToRemove = [
            "hasCompletedOnboarding",
            "hasSkippedOnboarding",
            "userNickname",
            "userProvider",
            "userUID",
            "hasSetNickname"
        ]
        
        for key in keysToRemove {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        UserDefaults.standard.synchronize()
        print("🟢 UserDefaults 완전 초기화 완료")
    }

    /// 사용자와 관련된 모든 Firestore 데이터를 삭제합니다
    /// - Parameters:
    ///   - uid: 삭제할 사용자 ID
    ///   - completion: 삭제 결과를 반환하는 콜백
    private func deleteFirestoreData(uid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        var deletionError: Error?
        
        group.enter()
        db.collection("users").document(uid).delete { error in
            if let error = error {
                print("🔴 users 문서 삭제 실패: \(error)")
                deletionError = error
            } else {
                print("🟢 users 문서 삭제 성공")
            }
            group.leave()
        }
        
        group.enter()
        db.collection("defaults").document(uid).delete { error in
            if let error = error {
                print("🔴 defaults 문서 삭제 실패: \(error)")
                deletionError = error
            } else {
                print("🟢 defaults 문서 삭제 성공")
            }
            group.leave()
        }
        
        group.enter()
        deleteAllSocialConnectionData(uid: uid) { error in
            if let error = error {
                deletionError = error
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if let error = deletionError {
                print("🔴 Firestore 데이터 삭제 중 오류 발생: \(error)")
                completion(.failure(error))
                return
            }
            
            Auth.auth().currentUser?.delete { error in
                if let error = error {
                    print("🔴 Firebase Auth 계정 삭제 실패: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                print("🟢 Firebase Auth 계정 삭제 성공 - 모든 데이터 완전 삭제")
                completion(.success(()))
            }
        }
    }

    /// 모든 소셜 로그인 제공자별 연결 데이터를 Firestore에서 삭제합니다
    /// - Parameters:
    ///   - uid: 사용자 ID
    ///   - completion: 삭제 완료를 알리는 콜백
    private func deleteAllSocialConnectionData(uid: String, completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        var deletionError: Error?
        
        group.enter()
        db.collection("users").whereField("kakaoId", isGreaterThan: 0).getDocuments { snapshot, error in
            if let error = error {
                deletionError = error
            } else if let documents = snapshot?.documents {
                for document in documents.filter({ $0.data()["uid"] as? String == uid }) {
                    document.reference.delete()
                    print("🟢 kakaoId 기반 문서 삭제: \(document.documentID)")
                }
            }
            group.leave()
        }
        
        group.enter()
        db.collection("users").whereField("googleId", isGreaterThan: "").getDocuments { snapshot, error in
            if let error = error {
                deletionError = error
            } else if let documents = snapshot?.documents {
                for document in documents.filter({ $0.data()["uid"] as? String == uid }) {
                    document.reference.delete()
                    print("🟢 googleId 기반 문서 삭제: \(document.documentID)")
                }
            }
            group.leave()
        }
        
        group.enter()
        db.collection("users").whereField("appleId", isGreaterThan: "").getDocuments { snapshot, error in
            if let error = error {
                deletionError = error
            } else if let documents = snapshot?.documents {
                for document in documents.filter({ $0.data()["uid"] as? String == uid }) {
                    document.reference.delete()
                    print("🟢 appleId 기반 문서 삭제: \(document.documentID)")
                }
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(deletionError)
        }
    }

    /// 익명 사용자를 위한 기본 Firestore 데이터를 설정합니다
    /// - Parameter uid: 사용자 ID
    private func setupDefaultFirestoreData(uid: String) {
        let userRef = db.collection("defaults").document(uid)
        userRef.setData(["createdAt": FieldValue.serverTimestamp()], merge: true)
        userRef.collection("Routine").addDocument(data: ["title": "기본루틴", "createdAt": FieldValue.serverTimestamp()])
        userRef.collection("Record").addDocument(data: ["note": "첫기록", "createdAt": FieldValue.serverTimestamp()])
        userRef.collection("UserSetting").document("default").setData(["unit": "kg"])
    }
}
