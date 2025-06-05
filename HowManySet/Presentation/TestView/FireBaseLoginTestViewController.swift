//
//  FireBaseLoginTestViewController.swift
//  HowManySet
//
//  Created by GO on 6/3/25.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import SnapKit
import Then
import KakaoSDKAuth
import KakaoSDKUser

class FireBaseLoginTestViewController: UIViewController {

    private let googleLoginButton = GIDSignInButton().then {
        $0.style = .iconOnly
        $0.colorScheme = .dark
    }
    // Kakao 로그인 버튼 (디자인은 자유롭게)
    private let kakaoLoginButton = UIButton(type: .system).then {
        $0.setTitle("카카오 로그인", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0) // 카카오 컬러
        $0.layer.cornerRadius = 24
        $0.titleLabel?.font = .boldSystemFont(ofSize: 16)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        setupGoogleSignIn()
        setupLayout()
        
        googleLoginButton.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
        kakaoLoginButton.addTarget(self, action: #selector(handleKakaoLogin), for: .touchUpInside)
    }

    private func setupGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Firebase clientID를 찾을 수 없습니다.")
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }

    private func setupLayout() {
        view.backgroundColor = .systemBackground
        view.addSubview(googleLoginButton)
        view.addSubview(kakaoLoginButton)
        
        googleLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-40)
            $0.width.height.equalTo(48)
        }
        kakaoLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(googleLoginButton.snp.bottom).offset(32)
            $0.width.equalTo(220)
            $0.height.equalTo(48)
        }
    }
    
    // 구글 로그인
    @objc private func handleGoogleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Firebase clientID를 찾을 수 없습니다.")
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error = error {
                print("Google Sign-In Error: \(error.localizedDescription)")
                return
            }
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Google user 정보 또는 ID 토큰이 없습니다.")
                return
            }
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Auth Error: \(error.localizedDescription)")
                    return
                }
                print("로그인 성공!")
                if let user = authResult?.user {
                    print("사용자 이메일: \(user.email ?? "없음")")
                    print("사용자 이름: \(user.displayName ?? "없음")")
                    print("사용자 UID: \(user.uid)")
                }
                DispatchQueue.main.async {
                    self?.handleLoginSuccess(title: "Google 로그인 성공", message: "Google 로그인이 완료되었습니다.")
                }
            }
        }
    }
    
    // 카카오 로그인
    @objc private func handleKakaoLogin() {
        // 카카오톡 설치 여부에 따라 로그인 방식 분기
        if UserApi.isKakaoTalkLoginAvailable() {
            // 카카오톡 앱으로 로그인
            UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
                self?.handleKakaoLoginResult(oauthToken: oauthToken, error: error)
            }
        } else {
            // 카카오 계정(웹)으로 로그인
            UserApi.shared.loginWithKakaoAccount { [weak self] oauthToken, error in
                self?.handleKakaoLoginResult(oauthToken: oauthToken, error: error)
            }
        }
    }
    
    private func handleKakaoLoginResult(oauthToken: OAuthToken?, error: Error?) {
        if let error = error {
            print("카카오 로그인 실패: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.handleLoginSuccess(title: "카카오 로그인 실패", message: error.localizedDescription)
            }
            return
        }
        guard let _ = oauthToken else {
            print("카카오 로그인 토큰이 없습니다.")
            DispatchQueue.main.async {
                self.handleLoginSuccess(title: "카카오 로그인 실패", message: "토큰이 없습니다.")
            }
            return
        }
        // 사용자 정보 조회 (테스트용)
        UserApi.shared.me { [weak self] user, error in
            if let error = error {
                print("카카오 사용자 정보 조회 실패: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.handleLoginSuccess(title: "카카오 로그인 실패", message: "사용자 정보 조회 실패")
                }
                return
            }
            let email = user?.kakaoAccount?.email ?? "이메일 없음"
            let nickname = user?.kakaoAccount?.profile?.nickname ?? "닉네임 없음"
            print("카카오 로그인 성공! 이메일: \(email), 닉네임: \(nickname)")
            DispatchQueue.main.async {
                self?.handleLoginSuccess(title: "카카오 로그인 성공", message: "이메일: \(email)\n닉네임: \(nickname)")
            }
        }
    }
    
    private func handleLoginSuccess(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
