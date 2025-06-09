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
import FirebaseFirestore
import AuthenticationServices
import GoogleSignIn
import KakaoSDKAuth
import KakaoSDKUser

class FireBaseLoginTestViewController: UIViewController {

    // MARK: - UI 요소
    private let logoView = UIImageView().then {
        $0.backgroundColor = UIColor(named: "AppColor")
        $0.layer.cornerRadius = 24
    }

    private let appleLoginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)

    private let googleLoginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black
        config.cornerStyle = .large
        config.title = "Google로 로그인"
        config.titleAlignment = .center
        config.image = UIImage(named: "Google")
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return button
    }()

    private let kakaoLoginButton = UIButton(type: .system).then {
        $0.setTitle("카카오로 시작하기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        $0.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0)
        $0.layer.cornerRadius = 12
        $0.setImage(UIImage(named: "Kakao"), for: .normal)
        $0.tintColor = .black
        $0.contentHorizontalAlignment = .center
    }

    private let anonymousLoginButton: UIButton = {
        let button = UIButton(type: .system)
        let title = "비회원으로 시작하기"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .underlineStyle: NSUnderlineStyle.single.rawValue
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

    // TODO: 카카오 권한 부족(비즈 앱 전환 해야함)
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
            guard let nickname = user?.kakaoAccount?.profile?.nickname,
                  let kakaoId = user?.id else {
                self?.showAlert(title: "카카오 정보 누락", message: "닉네임/id를 받아오지 못했습니다.")
                return
            }
            // 이메일 없이 Auth는 kakaoId 기반으로 진행
            self?.firebaseLoginOrRegisterWithoutEmail(kakaoId: kakaoId, nickname: nickname)
        }
    }


    // MARK: - Firebase Auth 연동 (이메일/비밀번호 방식)
    private func firebaseLoginOrRegisterWithoutEmail(kakaoId: Int64, nickname: String) {
        let email = "\(kakaoId)@kakao.com" // 임시 이메일 생성 (Firebase Auth는 이메일 필요)
        let password = "\(kakaoId)"
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let result = result {
                self?.saveUserToDB(uid: result.user.uid, nickname: nickname)
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                    if let result = result {
                        self?.saveUserToDB(uid: result.user.uid, nickname: nickname)
                    } else {
                        self?.showAlert(title: "Firebase Auth 실패", message: error?.localizedDescription ?? "알 수 없는 오류")
                    }
                }
            }
        }
    }

    // MARK: - Firestore에 사용자 정보 저장
    private func saveUserToDB(uid: String, nickname: String) {
        let db = Firestore.firestore()
        db.collection("uid").document(uid).setData([
            "name": nickname,
            "provider": "kakao"
        ]) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Firestore 저장 실패", message: error.localizedDescription)
            } else {
                self?.showAlert(title: "로그인 성공", message: "Firestore에 저장되었습니다.")
            }
        }
    }

    // MARK: - 기타 로그인(구글/애플/익명) 및 알림
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
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        showAlert(title: "Apple 로그인 실패", message: error.localizedDescription)
    }
}
