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
public final class AuthRepositoryImpl: AuthRepositoryProtocol {
    
    private let firebaseAuthService: FirebaseAuthServiceProtocol

    public init(firebaseAuthService: FirebaseAuthServiceProtocol) {
        self.firebaseAuthService = firebaseAuthService
    }

    /// 로그아웃 처리
    /// - Returns: 로그아웃 결과 Observable
    public func signOut() -> Observable<Void> {
        return Observable.create { observer in
            let result = self.firebaseAuthService.signOut()
            switch result {
            case .success:
                observer.onNext(())
                observer.onCompleted()
            case .failure(let error):
                observer.onError(error)
            }
            return Disposables.create()
        }
    }

    /// 계정 삭제 처리
    /// - Returns: 계정 삭제 결과 Observable
    public func deleteAccount() -> Observable<Void> {
        return Observable.create { observer in
            self.firebaseAuthService.deleteAccount { result in
                switch result {
                case .success:
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    /// 카카오 로그인 처리
    /// - Returns: 로그인된 사용자 정보 Observable
    public func signInWithKakao() -> Observable<User> {
        return Observable.create { observer in
            let loginHandler: ((OAuthToken?, Error?) -> Void) = { token, error in
                guard error == nil else {
                    observer.onError(error!)
                    return
                }

                UserApi.shared.me { user, error in
                    guard let user = user,
                          let nickname = user.kakaoAccount?.profile?.nickname,
                          let kakaoId = user.id else {
                        observer.onError(error ?? NSError(domain: "KakaoError", code: -1))
                        return
                    }

                    let email = "\(kakaoId)@kakao.com"
                    let password = "\(kakaoId)"
                    let kakaoEmail = user.kakaoAccount?.email

                    Auth.auth().signIn(withEmail: email, password: password) { result, error in
                        if let error = error as NSError?, error.code == AuthErrorCode.userNotFound.rawValue {
                            // 사용자가 없으면 새로 생성
                            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                                guard let result = result else {
                                    observer.onError(error ?? NSError(domain: "FirebaseCreateUser", code: -1))
                                    return
                                }
                                let userDTO = UserDTO(
                                    uid: result.user.uid,
                                    name: nickname,
                                    provider: "kakao",
                                    email: kakaoEmail
                                )
                                self.saveUserToFirestore(userDTO)
                                observer.onNext(userDTO.toEntity())
                                observer.onCompleted()
                            }
                        } else if let result = result {
                            let userDTO = UserDTO(
                                uid: result.user.uid,
                                name: nickname,
                                provider: "kakao",
                                email: kakaoEmail
                            )
                            self.saveUserToFirestore(userDTO)
                            observer.onNext(userDTO.toEntity())
                            observer.onCompleted()
                        } else {
                            observer.onError(error ?? NSError(domain: "FirebaseSignIn", code: -1))
                        }
                    }
                }
            }

            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk(completion: loginHandler)
            } else {
                UserApi.shared.loginWithKakaoAccount(completion: loginHandler)
            }

            return Disposables.create()
        }
    }

    /// 구글 로그인 처리
    /// - Returns: 로그인된 사용자 정보 Observable
    public func signInWithGoogle() -> Observable<User> {
        return Observable.create { observer in
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                observer.onError(NSError(domain: "NoRootVC", code: -1))
                return Disposables.create()
            }

            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    observer.onError(error ?? NSError(domain: "GoogleSignIn", code: -1))
                    return
                }

                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )

                Auth.auth().signIn(with: credential) { authResult, error in
                    guard let authResult = authResult else {
                        observer.onError(error ?? NSError(domain: "GoogleFirebaseAuth", code: -1))
                        return
                    }

                    let userDTO = UserDTO(
                        uid: authResult.user.uid,
                        name: user.profile?.name ?? "이름 없음",
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
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: token, rawNonce: nonce)

            Auth.auth().signIn(with: credential) { authResult, error in
                guard let authResult = authResult else {
                    observer.onError(error ?? NSError(domain: "AppleSignIn", code: -1))
                    return
                }

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
            self.firebaseAuthService.signInAnonymously { result in
                switch result {
                case .success(let user):
                    observer.onNext(user)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    /// 사용자 정보를 Firestore에 저장
    /// - Parameter dto: 저장할 사용자 정보 DTO
    private func saveUserToFirestore(_ dto: UserDTO) {
        let db = Firestore.firestore()
        db.collection("users").document(dto.uid).setData(dto.toFirestoreData(), merge: true) { error in
            if let error = error {
                print("Firestore 저장 실패: \(error.localizedDescription)")
            } else {
                print("Firestore 저장 성공")
            }
        }
    }
}
