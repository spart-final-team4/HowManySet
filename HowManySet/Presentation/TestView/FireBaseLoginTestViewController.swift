//
//  FireBaseLoginTestViewController.swift
//  HowManySet
//
//  Created by GO on 6/3/25.
//

import UIKit
import SnapKit
import Then
import FirebaseCore
import FirebaseAuth
import AuthenticationServices
import GoogleSignIn
import KakaoSDKAuth
import KakaoSDKUser

class FireBaseLoginTestViewController: UIViewController {

    // MARK: - UI 요소
    
    // TODO: 아이콘 추가 예정
    private let logoView = UIImageView().then {
        $0.backgroundColor = .systemGreen
        $0.layer.cornerRadius = 24
    }

    // Apple 공식 버튼
    private let appleLoginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)

    // Google 버튼 (공식 X 커스텀 O)
    private let googleLoginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black
        config.cornerStyle = .large
        config.title = "Google로 로그인"
        config.titleAlignment = .center
        config.image = UIImage(systemName: "g.circle") // Google 공식 아이콘 추가 필요
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)

        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return button
    }()

    // Kakao 공식 가이드 커스텀 버튼
    private let kakaoLoginButton = UIButton(type: .system).then {
        $0.setTitle("카카오로 시작하기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        $0.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0)
        $0.layer.cornerRadius = 12
        $0.setImage(UIImage(systemName: "bubble.fill"), for: .normal) // 공식 아이콘 필요
        $0.tintColor = .black
        $0.contentHorizontalAlignment = .center
    }

    // 익명 로그인
    private let anonymousLoginButton: UIButton = {
        let button = UIButton(type: .system)
        let title = "비회원으로 시작하기"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .underlineStyle: NSUnderlineStyle.single.rawValue // underLine 커스텀
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = .clear
        return button
    }()

    // MARK: - View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        [logoView, kakaoLoginButton, googleLoginButton, appleLoginButton, anonymousLoginButton].forEach {
            view.addSubview($0)
        }

        setupLayout()
        setupActions()
        setupGoogleSignIn()
    }

    // MARK: - Layout
    private func setupLayout() {
        logoView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(120)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(120)
        }
        kakaoLoginButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(56)
            $0.bottom.equalTo(googleLoginButton.snp.top).offset(-16)
        }
        googleLoginButton.snp.makeConstraints {
            $0.left.right.height.equalTo(kakaoLoginButton)
            $0.bottom.equalTo(appleLoginButton.snp.top).offset(-16)
        }
        appleLoginButton.snp.makeConstraints {
            $0.left.right.height.equalTo(kakaoLoginButton)
            $0.bottom.equalTo(anonymousLoginButton.snp.top).offset(-24)
        }
        anonymousLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
        }
    }

    // MARK: - Actions

    private func setupActions() {
        kakaoLoginButton.addTarget(self, action: #selector(handleKakaoLogin), for: .touchUpInside)
        googleLoginButton.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
        appleLoginButton.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
        anonymousLoginButton.addTarget(self, action: #selector(handleAnonymousLogin), for: .touchUpInside)
    }

    // MARK: - Google Sign-In 설정
    private func setupGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }

    // MARK: - 로그인 핸들러
    @objc private func handleKakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
                self?.handleKakaoLoginResult(oauthToken: oauthToken, error: error)
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { [weak self] oauthToken, error in
                self?.handleKakaoLoginResult(oauthToken: oauthToken, error: error)
            }
        }
    }

    private func handleKakaoLoginResult(oauthToken: OAuthToken?, error: Error?) {
        if let error = error {
            showAlert(title: "카카오 로그인 실패", message: error.localizedDescription)
            return
        }
        guard let _ = oauthToken else {
            showAlert(title: "카카오 로그인 실패", message: "토큰이 없습니다.")
            return
        }
        UserApi.shared.me { [weak self] user, error in
            if let error = error {
                self?.showAlert(title: "카카오 로그인 실패", message: error.localizedDescription)
                return
            }
            let email = user?.kakaoAccount?.email ?? "이메일 없음"
            let nickname = user?.kakaoAccount?.profile?.nickname ?? "닉네임 없음"
            self?.showAlert(title: "카카오 로그인 성공", message: "이메일: \(email)\n닉네임: \(nickname)")
        }
    }

    @objc private func handleGoogleLogin() {
        guard let presentingVC = UIApplication.shared.windows.first?.rootViewController else { return }
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { [weak self] result, error in
            if let error = error {
                self?.showAlert(title: "Google 로그인 실패", message: error.localizedDescription)
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                self?.showAlert(title: "Google 로그인 실패", message: "토큰이 없습니다.")
                return
            }
            let accessToken = user.accessToken.tokenString
            // Firebase 인증 연동 코드 추가 필요
            self?.showAlert(title: "Google 로그인 성공", message: user.profile?.email ?? "이메일 없음")
        }
    }

    @objc private func handleAppleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    @objc private func handleAnonymousLogin() {
        // Firebase Auth 익명 로그인 연동 코드 추가 필요
        showAlert(title: "비회원 로그인", message: "비회원으로 로그인되었습니다.")
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Apple 로그인 델리게이트
extension FireBaseLoginTestViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let email = appleIDCredential.email ?? "이메일 없음"
            let fullName = appleIDCredential.fullName?.givenName ?? "이름 없음"
            showAlert(title: "Apple 로그인 성공", message: "이메일: \(email)\n이름: \(fullName)\nUID: \(userIdentifier)")
            // Firebase Auth 연동 코드 추가 필요
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        showAlert(title: "Apple 로그인 실패", message: error.localizedDescription)
    }
}
