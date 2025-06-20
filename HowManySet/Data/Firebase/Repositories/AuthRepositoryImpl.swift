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
/// - Firebase Auth와 각종 소셜 로그인을 통합하여 처리
/// - Realm과 Firestore 데이터 동기화를 고려한 최소한의 코드 변경 구조
public final class AuthRepositoryImpl: AuthRepositoryProtocol {
    
    private let firebaseAuthService: FirebaseAuthServiceProtocol

    /// AuthRepositoryImpl 생성자
    /// - Parameter firebaseAuthService: Firebase 인증 서비스
    public init(firebaseAuthService: FirebaseAuthServiceProtocol) {
        self.firebaseAuthService = firebaseAuthService
    }

    /// 카카오 로그인 처리 (익명 로그인 방식으로 Firebase 연동)
    /// - Returns: 로그인된 사용자 정보 Observable
    public func signInWithKakao() -> Observable<User> {
        return Observable.create { observer in
            let loginHandler: ((OAuthToken?, Error?) -> Void) = { token, error in
                guard error == nil else {
                    print("🔥 카카오 로그인 실패: \(error!)")
                    observer.onError(error!)
                    return
                }
                
                UserApi.shared.me { user, error in
                    if let error = error {
                        print("🔥 카카오 사용자 정보 가져오기 실패: \(error.localizedDescription)")
                        observer.onError(error)
                        return
                    }
                    
                    guard let user = user,
                          let nickname = user.kakaoAccount?.profile?.nickname,
                          let kakaoId = user.id else {
                        print("🔥 카카오 사용자 정보 누락")
                        observer.onError(NSError(domain: "KakaoError", code: -1))
                        return
                    }
                    
                    print("🔥 카카오 사용자 정보 성공: \(nickname) / \(kakaoId)")
                    
                    // 기존 카카오 사용자 확인
                    let db = Firestore.firestore()
                    db.collection("users").whereField("kakaoId", isEqualTo: kakaoId).getDocuments { snapshot, error in
                        if let error = error {
                            print("🔥 Firestore 조회 실패: \(error)")
                            observer.onError(error)
                            return
                        }
                        
                        if let documents = snapshot?.documents, !documents.isEmpty {
                            // 기존 사용자 발견
                            let existingUserData = documents.first!.data()
                            if let uid = existingUserData["uid"] as? String {
                                print("🔥 기존 카카오 사용자 발견: \(uid)")
                                
                                // 기존 사용자로 Firebase 인증
                                let userDTO = UserDTO(
                                    uid: uid,
                                    name: nickname,
                                    provider: "kakao",
                                    email: user.kakaoAccount?.email
                                )
                                observer.onNext(userDTO.toEntity())
                                observer.onCompleted()
                                return
                            }
                        }
                        
                        // 새 사용자 - 익명 로그인 후 카카오 정보 연결
                        Auth.auth().signInAnonymously { authResult, error in
                            if let error = error {
                                print("🔥 익명 로그인 실패: \(error)")
                                observer.onError(error)
                                return
                            }
                            
                            guard let authResult = authResult else {
                                observer.onError(NSError(domain: "AnonymousSignIn", code: -1))
                                return
                            }
                            
                            print("🔥 익명 로그인 성공: \(authResult.user.uid)")
                            
                            // Firestore에 카카오 사용자 정보 저장
                            let userDTO = UserDTO(
                                uid: authResult.user.uid,
                                name: nickname,
                                provider: "kakao",
                                email: user.kakaoAccount?.email
                            )
                            
                            // 카카오 ID를 별도로 저장하여 중복 로그인 방지
                            var firestoreData = userDTO.toFirestoreData()
                            firestoreData["kakaoId"] = kakaoId
                            
                            db.collection("users").document(authResult.user.uid).setData(firestoreData, merge: true) { error in
                                if let error = error {
                                    print("🔥 Firestore 저장 실패: \(error)")
                                    observer.onError(error)
                                    return
                                }
                                
                                print("🔥 카카오 로그인 완료: \(authResult.user.uid)")
                                observer.onNext(userDTO.toEntity())
                                observer.onCompleted()
                            }
                        }
                    }
                }
            }

            if UserApi.isKakaoTalkLoginAvailable() {
                print("🔥 카카오톡 로그인 시도")
                UserApi.shared.loginWithKakaoTalk(completion: loginHandler)
            } else {
                print("🔥 카카오 계정 로그인 시도")
                UserApi.shared.loginWithKakaoAccount(completion: loginHandler)
            }

            return Disposables.create()
        }
    }

    /// 구글 로그인 처리
    /// - Returns: 로그인된 사용자 정보 Observable
    public func signInWithGoogle() -> Observable<User> {
        return Observable.create { observer in
            print("🔥 구글 로그인 시작")
            
            // Google Sign-In 설정 확인
            guard GIDSignIn.sharedInstance.configuration != nil else {
                print("🔥 Google Sign-In 설정 없음")
                observer.onError(NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google Sign-In not configured"]))
                return Disposables.create()
            }
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                print("🔥 RootViewController 없음")
                observer.onError(NSError(domain: "NoRootVC", code: -1))
                return Disposables.create()
            }

            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                if let error = error {
                    print("🔥 구글 로그인 실패: \(error)")
                    observer.onError(error)
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    print("🔥 구글 토큰 없음")
                    observer.onError(NSError(domain: "GoogleSignIn", code: -1))
                    return
                }

                print("🔥 구글 토큰 획득 성공")
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )

                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("🔥 Firebase 구글 로그인 실패: \(error)")
                        observer.onError(error)
                        return
                    }
                    
                    guard let authResult = authResult else {
                        print("🔥 Firebase 인증 결과 없음")
                        observer.onError(NSError(domain: "GoogleFirebaseAuth", code: -1))
                        return
                    }

                    print("🔥 구글 로그인 성공: \(authResult.user.uid)")
                    let userDTO = UserDTO(
                        uid: authResult.user.uid,
                        name: user.profile?.name ?? "구글 사용자",
                        provider: "google",
                        email: user.profile?.email
                    )
                    
                    self.saveUserToFirestore(userDTO)
                    observer.onNext(userDTO.toEntity())
                    observer.onCompleted()
                }
            }

            return Disposables.create()
        }
    }

    /// Apple 로그인 처리
    /// - Parameters:
    ///   - token: Apple ID 토큰
    ///   - nonce: 보안을 위한 nonce 값
    /// - Returns: 로그인된 사용자 정보 Observable
    public func signInWithApple(token: String, nonce: String) -> Observable<User> {
        return Observable.create { observer in
            print("🔥 Apple 로그인 시작")
            print("🔥 Token: \(token.prefix(50))...")
            print("🔥 Nonce: \(nonce)")
            
            // Firebase Console Apple 설정 확인을 위한 추가 로그
            print("🔥 Firebase Project ID: \(FirebaseApp.app()?.options.projectID ?? "Unknown")")
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: token, rawNonce: nonce)
            print("🔥 Firebase Credential 생성 완료")

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("🔥 Firebase Apple 로그인 실패: \(error)")
                    print("🔥 Error Code: \((error as NSError).code)")
                    print("🔥 Error Domain: \((error as NSError).domain)")
                    print("🔥 Error UserInfo: \((error as NSError).userInfo)")
                    
                    // 특정 에러 코드별 처리
                    let nsError = error as NSError
                    switch nsError.code {
                    case 17999: // ERROR_WEB_CONTEXT_CANCELED
                        print("🔥 사용자가 Apple 로그인을 취소했습니다")
                    case 17020: // ERROR_NETWORK_REQUEST_FAILED
                        print("🔥 네트워크 연결 문제입니다")
                    case 17004: // ERROR_INVALID_CREDENTIAL
                        print("🔥 Apple 인증 정보가 유효하지 않습니다 - Firebase Console 설정을 확인하세요")
                    default:
                        print("🔥 알 수 없는 Apple 로그인 에러")
                    }
                    
                    observer.onError(error)
                    return
                }
                
                guard let authResult = authResult else {
                    print("🔥 Apple AuthResult가 nil")
                    observer.onError(NSError(domain: "AppleSignIn", code: -1))
                    return
                }
                
                print("🔥 Apple 로그인 성공")
                print("🔥 UID: \(authResult.user.uid)")
                print("🔥 Email: \(authResult.user.email ?? "nil")")
                print("🔥 DisplayName: \(authResult.user.displayName ?? "nil")")

                let userDTO = UserDTO(
                    uid: authResult.user.uid,
                    name: authResult.user.displayName ?? "Apple 사용자",
                    provider: "apple",
                    email: authResult.user.email
                )
                
                self.saveUserToFirestore(userDTO)
                observer.onNext(userDTO.toEntity())
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }


    /// 익명 로그인 처리
    /// - Returns: 로그인된 사용자 정보 Observable
    public func signInAnonymously() -> Observable<User> {
        return Observable.create { observer in
            print("🔥 익명 로그인 시작")
            self.firebaseAuthService.signInAnonymously { result in
                switch result {
                case .success(let user):
                    print("🔥 익명 로그인 성공: \(user.uid)")
                    observer.onNext(user)
                    observer.onCompleted()
                case .failure(let error):
                    print("🔥 익명 로그인 실패: \(error)")
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    /// 로그아웃 처리
    /// - Returns: 로그아웃 결과 Observable
    public func signOut() -> Observable<Void> {
        return Observable.create { observer in
            print("🔥 로그아웃 시작")
            let result = self.firebaseAuthService.signOut()
            switch result {
            case .success:
                print("🔥 로그아웃 성공")
                observer.onNext(())
                observer.onCompleted()
            case .failure(let error):
                print("🔥 로그아웃 실패: \(error)")
                observer.onError(error)
            }
            return Disposables.create()
        }
    }

    /// 계정 삭제 처리
    /// - Returns: 계정 삭제 결과 Observable
    public func deleteAccount() -> Observable<Void> {
        return Observable.create { observer in
            print("🔥 계정 삭제 시작")
            self.firebaseAuthService.deleteAccount { result in
                switch result {
                case .success:
                    print("🔥 계정 삭제 성공")
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    print("🔥 계정 삭제 실패: \(error)")
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    /// 사용자 정보를 Firestore에 저장
    /// - Parameter dto: 저장할 사용자 정보 DTO
    /// - Note: Realm과 Firestore 데이터 동기화를 위한 구조
    private func saveUserToFirestore(_ dto: UserDTO) {
        let db = Firestore.firestore()
        db.collection("users").document(dto.uid).setData(dto.toFirestoreData(), merge: true) { error in
            if let error = error {
                print("🔥 Firestore 저장 실패: \(error.localizedDescription)")
            } else {
                print("🔥 Firestore 저장 성공: \(dto.uid)")
            }
        }
    }
}
