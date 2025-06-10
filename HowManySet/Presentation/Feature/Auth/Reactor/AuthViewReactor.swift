//
//  AuthViewReactor.swift
//  HowManySet
//
//  Created by GO on 6/3/25.
//

import Foundation
import ReactorKit
import RxSwift
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import CryptoKit
import KakaoSDKUser
import KakaoSDKAuth

/**
 인증 화면의 ViewModel 역할을 하는 ReactorKit 기반 클래스

 - 역할:
    - 인증 관련 사용자 액션(Action) 처리
    - 인증 결과에 따른 상태(Mutation, State) 관리
    - Google, Kakao, Apple, 익명 로그인 등 다양한 인증 방식 지원
    - 인증 성공 시 Firestore 등 백엔드 연동 가능

 - 사용 기술:
    - ReactorKit, RxSwift, FirebaseAuth, GoogleSignIn, KakaoSDK, CryptoKit
 */
final class AuthViewReactor: Reactor {

    // MARK: - Action

    /// 인증 화면에서 발생하는 사용자 액션(버튼 클릭 등)
    enum Action {
        /// 카카오 로그인 버튼 클릭
        case tapKakaoLogin
        /// 구글 로그인 버튼 클릭
        case tapGoogleLogin
        /// 애플 로그인 버튼 클릭
        case tapAppleLogin
        /// 애플 로그인 성공(토큰, nonce 전달)
        case appleDidAuthorize(token: String, nonce: String)
        /// 애플 로그인 실패
        case appleDidFail(error: Error)
        /// 비회원 로그인 버튼 클릭
        case tapAnonymousLogin
    }

    // MARK: - Mutation

    /// 상태 변화(로딩, 로그인 성공 등)를 나타내는 변이값
    enum Mutation {
        /// 로딩 상태 변경
        case setLoading(Bool)
        /// 로그인 성공 여부 변경
        case setLoggedIn(Bool)
    }

    // MARK: - State

    /// 인증 화면의 상태(로딩 여부, 로그인 성공 여부)
    struct State {
        /// 현재 로딩 중인지 여부
        var isLoading: Bool = false
        /// 로그인 성공 여부
        var isLoggedIn: Bool = false
    }

    /// ReactorKit에서 요구하는 초기 상태
    let initialState = State()

    // MARK: - mutate()

    /**
     사용자 액션에 따라 상태 변이를 반환합니다.

     - Parameters:
        - action: 사용자 액션
     - Returns: 상태 변이(Observable<Mutation>)
     */
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapKakaoLogin:
            // 카카오 로그인 플로우 시작
            return handleKakao()
        case .tapGoogleLogin:
            // 구글 로그인 플로우 시작
            return handleGoogle()
        case .tapAppleLogin:
            // 애플 로그인 요청(로딩 상태만 변경)
            return .just(.setLoading(true))
        case let .appleDidAuthorize(token, nonce):
            // 애플 로그인 성공 시 인증 처리
            return handleApple(token: token, nonce: nonce)
        case .appleDidFail:
            // 애플 로그인 실패 시 로딩 해제
            return .just(.setLoading(false))
        case .tapAnonymousLogin:
            // 비회원 로그인 플로우 시작
            return handleAnonymous()
        }
    }

    // MARK: - reduce()

    /**
     상태 변이에 따라 새로운 상태를 반환합니다.

     - Parameters:
        - state: 이전 상태
        - mutation: 상태 변이
     - Returns: 새로운 상태
     */
    func reduce(state: State, mutation: Mutation) -> State {
        var new = state
        switch mutation {
        case let .setLoading(l): new.isLoading = l
        case let .setLoggedIn(ok): new.isLoggedIn = ok; new.isLoading = false
        }
        return new
    }

    // MARK: - Utility Functions for Login Logic

    /**
     Apple 로그인용 nonce(임의의 문자열) 생성

     - Parameters:
        - length: 생성할 문자열 길이(기본값 32)
     - Returns: 임의의 nonce 문자열
     */
    func generateNonce(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        result.reserveCapacity(length)
        var random = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, length, &random)
        for byte in random {
            result.append(charset[Int(byte) % charset.count])
        }
        return result
    }

    /**
     입력 문자열의 SHA256 해시값 반환

     - Parameters:
        - input: 입력 문자열
     - Returns: 해시값 문자열
     */
    func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        return SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - 실제 로그인 처리 로직

    /**
     카카오 로그인 처리 및 Firestore 저장

     - Returns: 카카오 로그인 결과에 따른 상태 변이 Observable
     */
    private func handleKakao() -> Observable<Mutation> {
        return Observable.create { observer in
            // 카카오톡 또는 카카오계정으로 로그인
            let loginHandler: ((OAuthToken?, Error?) -> Void) = { token, error in
                if let error = error {
                    // 로그인 실패 시 로딩 해제
                    observer.onNext(.setLoading(false))
                    observer.onCompleted()
                    return
                }
                // 사용자 정보 가져오기
                UserApi.shared.me { user, error in
                    guard let user = user,
                          let nickname = user.kakaoAccount?.profile?.nickname,
                          let kakaoId = user.id else {
                        observer.onNext(.setLoading(false))
                        observer.onCompleted()
                        return
                    }
                    // 파이어베이스 이메일/비번 기반 로그인(최초 1회는 회원가입 필요)
                    let email = "\(kakaoId)@kakao.com"
                    let password = "\(kakaoId)"
                    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                        if let error = error as NSError?, error.code == AuthErrorCode.userNotFound.rawValue {
                            // 파이어베이스에 계정이 없으면 회원가입 후 로그인
                            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                                guard let uid = result?.user.uid else {
                                    observer.onNext(.setLoading(false))
                                    observer.onCompleted()
                                    return
                                }
                                // Firestore에 사용자 정보 저장
                                self.saveUserToFirestore(uid: uid, nickname: nickname, provider: "kakao")
                                observer.onNext(.setLoggedIn(true))
                                observer.onCompleted()
                            }
                        } else if let authResult = authResult {
                            // 기존 계정 로그인 성공
                            let uid = authResult.user.uid
                            self.saveUserToFirestore(uid: uid, nickname: nickname, provider: "kakao")
                            observer.onNext(.setLoggedIn(true))
                            observer.onCompleted()
                        } else {
                            observer.onNext(.setLoading(false))
                            observer.onCompleted()
                        }
                    }
                }
            }
            // 카카오톡 앱 설치 여부에 따라 로그인 방식 분기
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk(completion: loginHandler)
            } else {
                UserApi.shared.loginWithKakaoAccount(completion: loginHandler)
            }
            return Disposables.create()
        }
    }

    /**
     구글 로그인 처리 및 Firestore 저장

     - Returns: 구글 로그인 결과에 따른 상태 변이 Observable
     */
    private func handleGoogle() -> Observable<Mutation> {
        return Observable.create { observer in
            // 현재 앱의 최상위 rootViewController 필요
            guard let root = UIApplication.shared.windows.first?.rootViewController else {
                observer.onNext(.setLoading(false))
                observer.onCompleted()
                return Disposables.create()
            }
            // 구글 로그인 플로우 시작
            GIDSignIn.sharedInstance.signIn(withPresenting: root) { result, error in
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    observer.onNext(.setLoading(false))
                    observer.onCompleted()
                    return
                }
                // 구글 credential로 파이어베이스 인증
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )
                Auth.auth().signIn(with: credential) { authResult, error in
                    guard let authResult = authResult else {
                        observer.onNext(.setLoading(false))
                        observer.onCompleted()
                        return
                    }
                    let uid = authResult.user.uid
                    let nickname = user.profile?.name ?? "이름 없음"
                    // Firestore에 사용자 정보 저장
                    self.saveUserToFirestore(uid: uid, nickname: nickname, provider: "google")
                    observer.onNext(.setLoggedIn(true))
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

    /**
     애플 로그인 처리 및 Firestore 저장

     - Parameters:
        - token: 애플 인증 토큰
        - nonce: 무결성 검증용 nonce
     - Returns: 애플 로그인 결과에 따른 상태 변이 Observable
     */
    private func handleApple(token: String, nonce: String) -> Observable<Mutation> {
        return Observable.create { observer in
            // 애플 credential로 파이어베이스 인증
            let cred = OAuthProvider.credential(withProviderID: "apple.com", idToken: token, rawNonce: nonce)
            Auth.auth().signIn(with: cred) { authResult, error in
                guard let authResult = authResult else {
                    observer.onNext(.setLoading(false))
                    observer.onCompleted()
                    return
                }
                let uid = authResult.user.uid
                let nickname = authResult.user.displayName ?? "Apple 사용자"
                // Firestore에 사용자 정보 저장
                self.saveUserToFirestore(uid: uid, nickname: nickname, provider: "apple")
                observer.onNext(.setLoggedIn(true))
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    /**
     익명 로그인 처리 및 Firestore 저장

     - Returns: 익명 로그인 결과에 따른 상태 변이 Observable
     */
    private func handleAnonymous() -> Observable<Mutation> {
        return Observable.create { observer in
            Auth.auth().signInAnonymously { result, error in
                guard let result = result else {
                    observer.onNext(.setLoading(false))
                    observer.onCompleted()
                    return
                }
                let uid = result.user.uid
                // Firestore에 사용자 정보 저장
                self.saveUserToFirestore(uid: uid, nickname: "익명 사용자", provider: "anonymous")
                observer.onNext(.setLoggedIn(true))
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    /**
     Firestore에 사용자 정보 저장

     - Parameters:
        - uid: 파이어베이스 사용자 고유 ID
        - nickname: 사용자 닉네임
        - provider: 인증 제공자 (kakao, google, apple, anonymous)
     - Note:
        - users 컬렉션의 document ID로 uid 사용
        - name, provider, createdAt(서버타임스탬프) 필드 저장
        - merge: true로 중복 저장 방지
        - 저장 실패/성공 시 콘솔 로그 출력
     */
    private func saveUserToFirestore(uid: String, nickname: String, provider: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "name": nickname,
            "provider": provider,
            "createdAt": FieldValue.serverTimestamp()
        ], merge: true) { error in
            if let error = error {
                print("Firestore 저장 실패: \(error.localizedDescription)")
            } else {
                print("Firestore 저장 성공")
            }
        }
    }
}
