//
//  AuthViewController.swift
//  HowManySet
//
//  Created by GO on 6/3/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKUser
import CryptoKit

/**
 인증(로그인) 화면의 ViewController.

 - 역할:
    - 인증 관련 UI(AuthView)와 인증 흐름을 담당
    - ReactorKit을 통한 상태 관리 및 RxSwift 기반 이벤트 바인딩
    - Google, Apple, Kakao, 익명 로그인 등 다양한 인증 방식 지원
    - 인증 성공 시 Coordinator를 통해 인증 완료 플로우 진행

 - 사용 기술:
    - ReactorKit, RxSwift, Firebase, GoogleSignIn, AuthenticationServices(Apple), KakaoSDK
 */
final class AuthViewController: UIViewController, View {

    // MARK: - Properties

    /// RxSwift 리소스 해제용 DisposeBag. 바인딩 해제에 사용.
    var disposeBag = DisposeBag()
    /// 인증 상태 및 액션 관리를 위한 Reactor. View와 상태/액션을 연결.
    let reactor: AuthViewReactor
    /// 인증 완료 후 화면 전환을 담당하는 Coordinator. 인증 플로우 종료 시 호출됨.
    private weak var coordinator: AuthCoordinatorProtocol?
    /// 인증 관련 UI 요소를 포함하는 커스텀 뷰. 버튼, 타이틀 등 포함.
    private let authView = AuthView()
    /// Apple 로그인 시 nonce(임의 문자열) 저장용. 무결성 검증에 사용.
    private var currentNonce: String?

    // MARK: - Initialization

    /**
     AuthViewController 생성자

     - Parameters:
        - reactor: 인증 상태 및 액션 관리를 위한 ReactorKit 객체
        - coordinator: 인증 완료 후 화면 전환을 담당하는 Coordinator
     */
    init(reactor: AuthViewReactor, coordinator: AuthCoordinatorProtocol) {
        self.reactor = reactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    /**
     스토리보드 초기화는 지원하지 않음. 코드 기반 생성만 허용.
     */
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle

    /**
     인증 전용 UI(AuthView)로 뷰 교체.
     뷰 계층의 루트로 AuthView를 사용.
     */
    override func loadView() {
        view = authView
    }

    /**
     Google 설정 및 Reactor 바인딩.
     - GoogleSignIn 클라이언트 설정
     - 인증 버튼 등과 ReactorKit 상태/액션 바인딩
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGoogleConfiguration()
        bind(reactor: reactor)
    }

    // MARK: - ReactorKit Binding

    /**
     인증 UI와 ReactorKit 상태/액션을 바인딩합니다.

     - Parameters:
        - reactor: AuthViewReactor 인스턴스
     - 주요 바인딩:
        - 각 로그인 버튼의 Rx 이벤트를 reactor 액션으로 변환
        - 로그인 성공 시 coordinator의 completeAuth() 호출
     */
    func bind(reactor: AuthViewReactor) {
        /// 카카오 로그인 버튼 탭 이벤트를 reactor 액션으로 전달
        authView.kakaoLoginButton.rx.tap
            .map { AuthViewReactor.Action.tapKakaoLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        /// 구글 로그인 버튼 탭 이벤트를 reactor 액션으로 전달
        authView.googleLoginButton.rx.tap
            .map { AuthViewReactor.Action.tapGoogleLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        /// 애플 로그인 버튼은 Rx 확장이 없어 addTarget으로 처리
        authView.appleLoginButton.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)

        /// 비회원 로그인 버튼 탭 이벤트를 reactor 액션으로 전달
        authView.anonymousLoginButton.rx.tap
            .map { AuthViewReactor.Action.tapAnonymousLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        /// 로그인 성공 시 coordinator의 completeAuth() 호출로 인증 플로우 종료
        reactor.state.map { $0.isLoggedIn }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.completeAuth()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Apple 로그인 버튼 액션

    /**
     애플 로그인 버튼 클릭 시 호출.
     - nonce(임의 문자열) 생성은 reactor에서 호출
     - startAppleAuth로 로그인 요청 시작.
     */
    @objc private func handleAppleLogin() {
        let nonce = reactor.generateNonce()
        self.currentNonce = nonce
        self.startAppleAuth(nonce: nonce)
    }

    // MARK: - Google 설정

    /**
     Firebase에서 Google clientID를 읽어 GoogleSignIn 설정을 초기화.
     - FirebaseApp의 clientID를 GoogleSignIn에 전달.
     */
    private func setupGoogleConfiguration() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
    }

    // MARK: - Apple 로그인

    /**
     Apple 로그인 요청을 시작합니다.

     - Parameters:
        - nonce: 무결성 검증용 임의 문자열
     - 동작:
        - AppleIDProvider로 로그인 요청 생성
        - 요청에 nonce와 scope(이름, 이메일) 포함
        - ASAuthorizationController로 인증 요청 수행
     */
    private func startAppleAuth(nonce: String) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = reactor.sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

// MARK: - Apple 인증 Delegates

extension AuthViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    /**
     Apple 인증 프레젠테이션 Anchor 반환

     - Parameters:
        - controller: ASAuthorizationController
     - Returns: 현재 뷰의 윈도우
     - 설명: Apple 인증 시 어떤 윈도우에서 인증 UI가 뜰지 지정
     */
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }

    /**
     Apple 인증 성공 시 호출. 인증 결과를 reactor에 전달.

     - Parameters:
        - controller: ASAuthorizationController
        - authorization: ASAuthorization (Apple 인증 결과)
     - 동작:
        - AppleIDCredential에서 identityToken 추출
        - nonce와 함께 reactor 액션으로 전달
     */
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let tokenData = credential.identityToken,
              let tokenString = String(data: tokenData, encoding: .utf8)
        else {
            return
        }
        reactor.action.onNext(.appleDidAuthorize(token: tokenString, nonce: nonce))
    }

    /**
     Apple 인증 실패 시 호출. 에러를 reactor에 전달.

     - Parameters:
        - controller: ASAuthorizationController
        - error: Error (인증 실패 원인)
     */
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        reactor.action.onNext(.appleDidFail(error: error))
    }
}
