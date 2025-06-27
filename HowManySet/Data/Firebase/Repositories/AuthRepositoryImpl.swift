//
//  AuthRepositoryImpl.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import UIKit
import RxSwift
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import GoogleSignIn
import KakaoSDKAuth
import KakaoSDKUser

/// 인증 관련 데이터 처리를 담당하는 Repository 구현체
///
/// Firebase Auth와 각종 소셜 로그인을 통합하여 처리
/// 로그아웃 후 재로그인 문제를 해결하여 온보딩 상태를 올바르게 유지
public final class AuthRepositoryImpl: AuthRepositoryProtocol {
    
    private let firebaseAuthService: FirebaseAuthServiceProtocol

    /// AuthRepositoryImpl 인스턴스를 생성합니다
    /// - Parameter firebaseAuthService: Firebase 인증 서비스 프로토콜 구현체
    public init(firebaseAuthService: FirebaseAuthServiceProtocol) {
        self.firebaseAuthService = firebaseAuthService
    }

    /// 카카오 계정으로 로그인을 수행합니다
    ///
    /// 로그아웃 후 재로그인 시 기존 온보딩 상태를 유지하도록 개선되었습니다.
    /// Firebase Auth 상태와 무관하게 Firestore에서 기존 사용자를 조회합니다.
    /// - Returns: 로그인된 사용자 정보를 방출하는 Observable
    public func signInWithKakao() -> Observable<User> {
        return Observable.create { observer in
            let loginHandler: ((OAuthToken?, Error?) -> Void) = { token, error in
                guard error == nil else {
                    print("카카오 로그인 실패: \(error!)")
                    observer.onError(error!)
                    return
                }
                
                UserApi.shared.me { user, error in
                    if let error = error {
                        print("카카오 사용자 정보 가져오기 실패: \(error.localizedDescription)")
                        observer.onError(error)
                        return
                    }
                    
                    guard let user = user,
                          let nickname = user.kakaoAccount?.profile?.nickname,
                          let kakaoId = user.id else {
                        print("카카오 사용자 정보 누락")
                        observer.onError(NSError(domain: "KakaoError", code: -1))
                        return
                    }
                    
                    print("카카오 사용자 정보 성공: \(nickname) / \(kakaoId)")
                    
                    self.findExistingKakaoUser(kakaoId: kakaoId)
                        .subscribe(
                            onNext: { existingUser in
                                if let existingUser = existingUser {
                                    print("🟢 기존 카카오 사용자 발견: \(existingUser.uid)")
                                    print("🔍 기존 사용자 온보딩 상태: hasSetNickname=\(existingUser.hasSetNickname), hasCompletedOnboarding=\(existingUser.hasCompletedOnboarding)")
                                    
                                    self.reconnectExistingKakaoUser(existingUser, kakaoId: kakaoId, nickname: nickname, email: user.kakaoAccount?.email) { result in
                                        switch result {
                                        case .success(let user):
                                            observer.onNext(user)
                                            observer.onCompleted()
                                        case .failure(let error):
                                            observer.onError(error)
                                        }
                                    }
                                } else {
                                    print("🔴 새로운 카카오 사용자 - 계정 생성")
                                    self.createNewKakaoUser(kakaoId: kakaoId, nickname: nickname, email: user.kakaoAccount?.email) { result in
                                        switch result {
                                        case .success(let user):
                                            observer.onNext(user)
                                            observer.onCompleted()
                                        case .failure(let error):
                                            observer.onError(error)
                                        }
                                    }
                                }
                            },
                            onError: { error in
                                print("기존 사용자 조회 실패: \(error)")
                                observer.onError(error)
                            }
                        )
                }
            }

            if UserApi.isKakaoTalkLoginAvailable() {
                print("카카오톡 로그인 시도")
                UserApi.shared.loginWithKakaoTalk(completion: loginHandler)
            } else {
                print("카카오 계정 로그인 시도")
                UserApi.shared.loginWithKakaoAccount(completion: loginHandler)
            }

            return Disposables.create()
        }
    }

    /// 구글 계정으로 로그인을 수행합니다
    ///
    /// Firebase Auth와 직접 연결하여 안정적인 로그인을 제공합니다.
    /// - Returns: 로그인된 사용자 정보를 방출하는 Observable
    public func signInWithGoogle() -> Observable<User> {
        return Observable.create { observer in
            print("구글 로그인 시작")
            
            guard GIDSignIn.sharedInstance.configuration != nil else {
                print("Google Sign-In 설정 없음")
                observer.onError(NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google Sign-In not configured"]))
                return Disposables.create()
            }
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                print("RootViewController 없음")
                observer.onError(NSError(domain: "NoRootVC", code: -1))
                return Disposables.create()
            }

            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                if let error = error {
                    print("구글 로그인 실패: \(error)")
                    observer.onError(error)
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    print("구글 토큰 없음")
                    observer.onError(NSError(domain: "GoogleSignIn", code: -1))
                    return
                }

                print("구글 토큰 획득 성공")
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )

                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Firebase 구글 로그인 실패: \(error)")
                        observer.onError(error)
                        return
                    }
                    
                    guard let authResult = authResult else {
                        print("Firebase 인증 결과 없음")
                        observer.onError(NSError(domain: "GoogleFirebaseAuth", code: -1))
                        return
                    }

                    print("🟢 구글 로그인 성공: \(authResult.user.uid)")
                    
                    self.fetchUserInfo(uid: authResult.user.uid)
                        .subscribe(
                            onNext: { firestoreUser in
                                if let firestoreUser = firestoreUser {
                                    print("🟢 기존 구글 사용자 Firestore 정보 발견")
                                    observer.onNext(firestoreUser)
                                } else {
                                    print("🔴 새로운 구글 사용자 - Firestore 정보 생성")
                                    let newUserDTO = UserDTO(
                                        uid: authResult.user.uid,
                                        name: user.profile?.name ?? "구글 사용자",
                                        provider: "google",
                                        email: user.profile?.email,
                                        hasSetNickname: false,
                                        hasCompletedOnboarding: false,
                                        googleId: user.userID
                                    )
                                    
                                    self.saveUserToFirestore(newUserDTO)
                                    observer.onNext(newUserDTO.toEntity())
                                }
                                observer.onCompleted()
                            },
                            onError: { error in
                                print("Firestore 사용자 정보 조회 실패: \(error)")
                                let userDTO = UserDTO(
                                    uid: authResult.user.uid,
                                    name: user.profile?.name ?? "구글 사용자",
                                    provider: "google",
                                    email: user.profile?.email,
                                    hasSetNickname: false,
                                    hasCompletedOnboarding: false,
                                    googleId: user.userID
                                )
                                self.saveUserToFirestore(userDTO)
                                observer.onNext(userDTO.toEntity())
                                observer.onCompleted()
                            }
                        )
                }
            }

            return Disposables.create()
        }
    }

    /// Apple ID로 로그인을 수행합니다
    ///
    /// Firebase Auth와 직접 연결하여 안정적인 로그인을 제공합니다.
    /// - Parameters:
    ///   - token: Apple ID 토큰
    ///   - nonce: 보안을 위한 nonce 값
    /// - Returns: 로그인된 사용자 정보를 방출하는 Observable
    public func signInWithApple(token: String, nonce: String) -> Observable<User> {
        return Observable.create { observer in
            print("Apple 로그인 시작")
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: token, rawNonce: nonce)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Apple 로그인 실패: \(error)")
                    observer.onError(error)
                    return
                }
                
                guard let authResult = authResult else {
                    print("Apple AuthResult가 nil")
                    observer.onError(NSError(domain: "AppleSignIn", code: -1))
                    return
                }
                
                print("🟢 Apple 로그인 성공: \(authResult.user.uid)")

                self.fetchUserInfo(uid: authResult.user.uid)
                    .subscribe(
                        onNext: { firestoreUser in
                            if let firestoreUser = firestoreUser {
                                print("🟢 기존 Apple 사용자 Firestore 정보 발견")
                                observer.onNext(firestoreUser)
                            } else {
                                print("🔴 새로운 Apple 사용자 - Firestore 정보 생성")
                                let newUserDTO = UserDTO(
                                    uid: authResult.user.uid,
                                    name: authResult.user.displayName ?? "Apple 사용자",
                                    provider: "apple",
                                    email: authResult.user.email,
                                    hasSetNickname: false,
                                    hasCompletedOnboarding: false,
                                    appleId: authResult.user.uid
                                )
                                
                                self.saveUserToFirestore(newUserDTO)
                                observer.onNext(newUserDTO.toEntity())
                            }
                            observer.onCompleted()
                        },
                        onError: { error in
                            print("Firestore 사용자 정보 조회 실패: \(error)")
                            let userDTO = UserDTO(
                                uid: authResult.user.uid,
                                name: authResult.user.displayName ?? "Apple 사용자",
                                provider: "apple",
                                email: authResult.user.email,
                                hasSetNickname: false,
                                hasCompletedOnboarding: false,
                                appleId: authResult.user.uid
                            )
                            self.saveUserToFirestore(userDTO)
                            observer.onNext(userDTO.toEntity())
                            observer.onCompleted()
                        }
                    )
            }

            return Disposables.create()
        }
    }

    /// 익명 로그인을 수행합니다
    /// - Returns: 익명 사용자 정보를 방출하는 Observable
    public func signInAnonymously() -> Observable<User> {
        return Observable.create { observer in
            print("익명 로그인 시작")
            self.firebaseAuthService.signInAnonymously { result in
                switch result {
                case .success(let user):
                    print("익명 로그인 성공: \(user.uid)")
                    observer.onNext(user)
                    observer.onCompleted()
                case .failure(let error):
                    print("익명 로그인 실패: \(error)")
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    /// 현재 사용자를 로그아웃시킵니다
    /// - Returns: 로그아웃 완료를 알리는 Observable
    public func signOut() -> Observable<Void> {
        return Observable.create { observer in
            print("로그아웃 시작")
            let result = self.firebaseAuthService.signOut()
            switch result {
            case .success:
                print("로그아웃 성공")
                observer.onNext(())
                observer.onCompleted()
            case .failure(let error):
                print("로그아웃 실패: \(error)")
                observer.onError(error)
            }
            return Disposables.create()
        }
    }

    /// 현재 사용자의 계정을 완전히 삭제합니다
    /// - Returns: 계정 삭제 완료를 알리는 Observable
    public func deleteAccount() -> Observable<Void> {
        return Observable.create { observer in
            print("계정 삭제 시작")
            self.firebaseAuthService.deleteAccount { result in
                switch result {
                case .success:
                    print("계정 삭제 성공")
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    print("계정 삭제 실패: \(error)")
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    /// 특정 사용자의 정보를 Firestore에서 조회합니다
    /// - Parameter uid: 조회할 사용자의 고유 식별자
    /// - Returns: 사용자 정보를 방출하는 Observable (사용자가 없으면 nil)
    public func fetchUserInfo(uid: String) -> Observable<User?> {
        return Observable.create { observer in
            let db = Firestore.firestore()
            db.collection("users").document(uid).getDocument { snapshot, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let document = snapshot, document.exists,
                      let data = document.data(),
                      let userDTO = UserDTO.from(uid: uid, data: data) else {
                    observer.onNext(nil)
                    observer.onCompleted()
                    return
                }
                
                observer.onNext(userDTO.toEntity())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    /// 사용자의 닉네임을 업데이트합니다
    ///
    /// setData with merge를 사용하여 문서가 없으면 생성하고 있으면 업데이트합니다.
    /// - Parameters:
    ///   - uid: 사용자 고유 식별자
    ///   - nickname: 새로운 닉네임
    /// - Returns: 업데이트 완료를 알리는 Observable
    public func updateUserNickname(uid: String, nickname: String) -> Observable<Void> {
        return Observable.create { observer in
            let db = Firestore.firestore()
            db.collection("users").document(uid).setData([
                "uid": uid,
                "name": nickname,
                "hasSetNickname": true,
                "lastUpdatedAt": FieldValue.serverTimestamp()
            ], merge: true) { error in
                if let error = error {
                    print("🔴 닉네임 업데이트 실패: \(error)")
                    observer.onError(error)
                    return
                }
                print("🟢 닉네임 Firestore 업데이트 성공: \(nickname)")
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    /// 사용자의 온보딩 완료 상태를 업데이트합니다
    ///
    /// setData with merge를 사용하여 문서가 없으면 생성하고 있으면 업데이트합니다.
    /// - Parameters:
    ///   - uid: 사용자 고유 식별자
    ///   - completed: 온보딩 완료 여부
    /// - Returns: 업데이트 완료를 알리는 Observable
    public func updateOnboardingStatus(uid: String, completed: Bool) -> Observable<Void> {
        return Observable.create { observer in
            let db = Firestore.firestore()
            var updateData: [String: Any] = [
                "uid": uid,
                "hasCompletedOnboarding": completed,
                "lastUpdatedAt": FieldValue.serverTimestamp()
            ]
            
            if completed {
                updateData["onboardingCompletedAt"] = FieldValue.serverTimestamp()
            }
            
            db.collection("users").document(uid).setData(updateData, merge: true) { error in
                if let error = error {
                    print("🔴 온보딩 상태 업데이트 실패: \(error)")
                    observer.onError(error)
                    return
                }
                print("🟢 온보딩 상태 Firestore 업데이트 성공: \(completed)")
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    /// 사용자의 온보딩 상태를 초기화합니다
    /// - Parameter uid: 사용자 고유 식별자
    /// - Returns: 초기화 완료를 알리는 Observable
    public func resetUserOnboardingStatus(uid: String) -> Observable<Void> {
        return Observable.create { observer in
            let db = Firestore.firestore()
            db.collection("users").document(uid).setData([
                "uid": uid,
                "hasSetNickname": false,
                "hasCompletedOnboarding": false,
                "lastUpdatedAt": FieldValue.serverTimestamp()
            ], merge: true) { error in
                if let error = error {
                    print("Firestore 온보딩 상태 초기화 실패: \(error)")
                    observer.onError(error)
                    return
                }
                print("Firestore 온보딩 상태 초기화 성공")
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    /// 현재 로그인된 사용자의 정보를 가져옵니다
    ///
    /// Firebase Auth 사용자가 있으면 Firestore에서 상세 정보를 조회하고,
    /// 없으면 Firebase Auth 기본 정보를 사용합니다.
    /// - Returns: 현재 사용자 정보를 방출하는 Observable (로그인되지 않은 경우 nil)
    public func getCurrentUser() -> Observable<User?> {
        return Observable.create { observer in
            if let currentUser = Auth.auth().currentUser {
                self.fetchUserInfo(uid: currentUser.uid)
                    .subscribe(
                        onNext: { firestoreUser in
                            if let firestoreUser = firestoreUser {
                                observer.onNext(firestoreUser)
                            } else {
                                let user = User(
                                    uid: currentUser.uid,
                                    name: currentUser.displayName ?? "사용자",
                                    provider: "firebase",
                                    email: currentUser.email
                                )
                                observer.onNext(user)
                            }
                            observer.onCompleted()
                        },
                        onError: { error in
                            print("Firestore 사용자 정보 조회 실패: \(error)")
                            let user = User(
                                uid: currentUser.uid,
                                name: currentUser.displayName ?? "사용자",
                                provider: "firebase",
                                email: currentUser.email
                            )
                            observer.onNext(user)
                            observer.onCompleted()
                        }
                    )
            } else {
                observer.onNext(nil)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    /// 소셜 로그인 제공자별 고유 식별자로 기존 사용자를 찾습니다
    ///
    /// 계정 삭제 후 재로그인 시 새 사용자로 처리하도록 개선되었습니다.
    /// Firebase Auth에서 해당 사용자가 실제로 존재하는지 확인합니다.
    /// - Parameters:
    ///   - kakaoId: 카카오 사용자 고유 식별자 (선택적)
    ///   - googleId: 구글 사용자 고유 식별자 (선택적)
    ///   - appleId: Apple 사용자 고유 식별자 (선택적)
    /// - Returns: 기존 사용자 정보를 방출하는 Observable (없으면 nil)
    public func findExistingUser(kakaoId: Int64?, googleId: String?, appleId: String?) -> Observable<User?> {
        return Observable.create { observer in
            let db = Firestore.firestore()
            var query: Query?
            
            if let kakaoId = kakaoId {
                query = db.collection("users").whereField("kakaoId", isEqualTo: kakaoId)
            } else if let googleId = googleId {
                query = db.collection("users").whereField("googleId", isEqualTo: googleId)
            } else if let appleId = appleId {
                query = db.collection("users").whereField("appleId", isEqualTo: appleId)
            }
            
            guard let query = query else {
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create()
            }
            
            query.getDocuments { snapshot, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("🔴 기존 사용자 없음 - 새 사용자로 처리")
                    observer.onNext(nil)
                    observer.onCompleted()
                    return
                }
                
                let firstDoc = documents.first!
                let uid = firstDoc.documentID
                
                if let currentUser = Auth.auth().currentUser, currentUser.uid == uid {
                    if let userDTO = UserDTO.from(uid: uid, data: firstDoc.data()) {
                        print("🟢 유효한 기존 사용자 발견: \(uid)")
                        observer.onNext(userDTO.toEntity())
                    } else {
                        print("🔴 잘못된 사용자 데이터 - 새 사용자로 처리")
                        observer.onNext(nil)
                    }
                    observer.onCompleted()
                } else {
                    print("🔴 Firebase Auth에 없는 사용자 또는 계정 삭제 후 재로그인 - Firestore 문서 삭제")
                    firstDoc.reference.delete { _ in
                        print("🟢 기존 Firestore 문서 삭제 완료 - 새 사용자로 처리")
                        observer.onNext(nil)
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }

    // MARK: - Private Methods

    /// Firebase Auth 상태와 무관하게 카카오 사용자를 직접 조회합니다
    ///
    /// 로그아웃 후 재로그인 문제를 해결하기 위해 추가된 메서드입니다.
    /// - Parameter kakaoId: 카카오 사용자 고유 식별자
    /// - Returns: 기존 사용자 정보를 방출하는 Observable (없으면 nil)
    private func findExistingKakaoUser(kakaoId: Int64) -> Observable<User?> {
        return Observable.create { observer in
            let db = Firestore.firestore()
            
            db.collection("users").whereField("kakaoId", isEqualTo: kakaoId).getDocuments { snapshot, error in
                if let error = error {
                    print("🔴 카카오 기존 사용자 조회 실패: \(error)")
                    observer.onError(error)
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("🔴 카카오 기존 사용자 없음")
                    observer.onNext(nil)
                    observer.onCompleted()
                    return
                }
                
                let firstDoc = documents.first!
                let uid = firstDoc.documentID
                
                if let userDTO = UserDTO.from(uid: uid, data: firstDoc.data()) {
                    print("🟢 카카오 기존 사용자 발견: \(uid)")
                    print("🔍 온보딩 상태: hasSetNickname=\(userDTO.hasSetNickname), hasCompletedOnboarding=\(userDTO.hasCompletedOnboarding)")
                    observer.onNext(userDTO.toEntity())
                } else {
                    print("🔴 카카오 사용자 데이터 파싱 실패")
                    observer.onNext(nil)
                }
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }

    /// 기존 카카오 사용자의 Firebase Auth를 재연결합니다
    ///
    /// 기존 온보딩 상태를 유지하면서 새로운 Firebase Auth UID로 업데이트합니다.
    /// - Parameters:
    ///   - user: 기존 사용자 정보
    ///   - kakaoId: 카카오 사용자 고유 식별자
    ///   - nickname: 사용자 닉네임
    ///   - email: 사용자 이메일 (선택적)
    ///   - completion: 재연결 결과를 반환하는 콜백
    private func reconnectExistingKakaoUser(_ user: User, kakaoId: Int64, nickname: String, email: String?, completion: @escaping (Result<User, Error>) -> Void) {
        print("🔄 기존 카카오 사용자 Firebase Auth 재연결 시작")
        
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                print("🔴 Firebase Auth 재연결 실패: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let authResult = authResult else {
                completion(.failure(NSError(domain: "AnonymousSignIn", code: -1)))
                return
            }
            
            print("🟢 Firebase Auth 재연결 성공: \(authResult.user.uid)")
            
            let updatedUserDTO = UserDTO(
                uid: authResult.user.uid,
                name: user.name,
                provider: "kakao",
                email: email,
                hasSetNickname: user.hasSetNickname,
                hasCompletedOnboarding: user.hasCompletedOnboarding,
                kakaoId: kakaoId
            )
            
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).delete { deleteError in
                if let deleteError = deleteError {
                    print("🔴 기존 문서 삭제 실패: \(deleteError)")
                }
                
                self.saveUserToFirestore(updatedUserDTO)
                
                print("🟢 기존 카카오 사용자 재연결 완료 - 온보딩 상태 유지")
                completion(.success(updatedUserDTO.toEntity()))
            }
        }
    }

    /// 새로운 카카오 사용자를 생성합니다
    /// - Parameters:
    ///   - kakaoId: 카카오 사용자 고유 식별자
    ///   - nickname: 사용자 닉네임
    ///   - email: 사용자 이메일 (선택적)
    ///   - completion: 생성 결과를 반환하는 콜백
    private func createNewKakaoUser(kakaoId: Int64, nickname: String, email: String?, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let authResult = authResult else {
                completion(.failure(NSError(domain: "AnonymousSignIn", code: -1)))
                return
            }
            
            print("🟢 새 카카오 사용자 생성: \(authResult.user.uid)")
            
            let userDTO = UserDTO(
                uid: authResult.user.uid,
                name: nickname,
                provider: "kakao",
                email: email,
                hasSetNickname: false,
                hasCompletedOnboarding: false,
                kakaoId: kakaoId
            )
            
            self.saveUserToFirestore(userDTO)
            completion(.success(userDTO.toEntity()))
        }
    }

    /// 사용자 정보를 Firestore에 저장합니다
    ///
    /// setData with merge를 사용하여 문서가 없으면 생성하고 있으면 병합합니다.
    /// - Parameter dto: 저장할 사용자 정보 DTO
    private func saveUserToFirestore(_ dto: UserDTO) {
        let db = Firestore.firestore()
        db.collection("users").document(dto.uid).setData(dto.toFirestoreData(), merge: true) { error in
            if let error = error {
                print("🔴 Firestore 저장 실패: \(error.localizedDescription)")
            } else {
                print("🟢 Firestore 저장 성공: \(dto.uid)")
            }
        }
    }
}
