//
//  FireBaseLoginTestViewController.swift
//  HowManySet
//
//  Created by GO on 6/3/25.
//

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
import CryptoKit
import AuthenticationServices

class FireBaseLoginTestViewController: UIViewController {

    // 난수
    private var currentNonce: String?
    
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

        view.addSubviews(logoView, kakaoLoginButton, googleLoginButton, appleLoginButton, anonymousLoginButton)

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
}

// MARK: - 카카오 로그인

extension FireBaseLoginTestViewController {
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
            guard let nickname = user?.kakaoAccount?.profile?.nickname,
                  let kakaoId = user?.id else {
                self?.showAlert(title: "카카오 정보 누락", message: "닉네임/id를 받아오지 못했습니다.")
                return
            }
            self?.firebaseLoginOrRegisterWithoutEmail(kakaoId: kakaoId, nickname: nickname)
        }
    }

    private func firebaseLoginOrRegisterWithoutEmail(kakaoId: Int64, nickname: String) {
        let email = "\(kakaoId)@kakao.com"
        let password = "\(kakaoId)"
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let result = result {
                self?.saveUserToDB(uid: result.user.uid, nickname: nickname, provider: "kakao")
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                    if let result = result {
                        self?.saveUserToDB(uid: result.user.uid, nickname: nickname, provider: "kakao")
                    } else {
                        self?.showAlert(title: "Firebase Auth 실패", message: error?.localizedDescription ?? "알 수 없는 오류")
                    }
                }
            }
        }
    }
}

// MARK: - 구글 로그인

extension FireBaseLoginTestViewController {
    @objc private func handleGoogleLogin() {
        guard let presentingVC = UIApplication.shared.windows.first?.rootViewController else { return }
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { [weak self] result, error in
            if let error = error {
                self?.showAlert(title: "Google 로그인 실패", message: error.localizedDescription)
                return
            }
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self?.showAlert(title: "Google 로그인 실패", message: "토큰이 없습니다.")
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self?.showAlert(title: "Firebase 로그인 실패", message: error.localizedDescription)
                    return
                }

                guard let authUser = authResult?.user else {
                    self?.showAlert(title: "Firebase 로그인 실패", message: "유저 정보가 없습니다.")
                    return
                }

                self?.saveUserToDB(uid: authUser.uid,
                                   nickname: user.profile?.name ?? "이름 없음",
                                   provider: "google")
            }
        }
    }
}

// MARK: - 애플 로그인

extension FireBaseLoginTestViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    @objc private func handleAppleLogin() {
        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            showAlert(title: "Apple 로그인 실패", message: "인증 정보 없음")
            return
        }

        guard let nonce = currentNonce else {
            fatalError("Nonce가 없어 Firebase 인증 불가")
        }

        guard let identityToken = credential.identityToken,
              let idTokenString = String(data: identityToken, encoding: .utf8) else {
            showAlert(title: "Apple 로그인 실패", message: "토큰 변환 실패")
            return
        }

        let firebaseCredential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )

        Auth.auth().signIn(with: firebaseCredential) { [weak self] authResult, error in
            if let error = error {
                self?.showAlert(title: "Firebase 로그인 실패", message: error.localizedDescription)
                return
            }

            let uid = authResult?.user.uid ?? credential.user
            let name = credential.fullName?.givenName ?? "이름 없음"

            self?.saveUserToDB(uid: uid, nickname: name, provider: "apple")
        }
    }


    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        showAlert(title: "Apple 로그인 실패", message: error.localizedDescription)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - 익명 로그인

extension FireBaseLoginTestViewController {
    @objc private func handleAnonymousLogin() {
        Auth.auth().signInAnonymously { [weak self] result, error in
            if let result = result {
                self?.saveUserToDB(uid: result.user.uid, nickname: "익명 사용자", provider: "anonymous")
            } else {
                self?.showAlert(title: "익명 로그인 실패", message: error?.localizedDescription ?? "알 수 없는 오류")
            }
        }
    }
}

// MARK: - Firestore 저장 및 공통 Alert

extension FireBaseLoginTestViewController {
    private func saveUserToDB(uid: String, nickname: String, provider: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "name": nickname,
            "provider": provider
        ]) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Firestore 저장 실패", message: error.localizedDescription)
            } else {
                self?.showAlert(title: "로그인 성공", message: "Firestore에 저장되었습니다.")
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - nonce
extension FireBaseLoginTestViewController {
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }
}
