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

class FireBaseLoginTestViewController: UIViewController {

    private let googleLoginButton = GIDSignInButton().then {
        $0.style = .iconOnly  // 로고만 표시
        $0.colorScheme = .dark
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        setupGoogleSignIn()
        setupLayout()
        
        // GIDSignInButton 클릭 시 Firebase 인증까지 처리하도록 타겟 추가
        googleLoginButton.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
    }

    private func setupGoogleSignIn() {
        // Firebase에서 clientID 가져오기
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Firebase clientID를 찾을 수 없습니다.")
            return
        }
        
        // Google Sign-In 구성
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }

    private func setupLayout() {
        view.backgroundColor = .systemBackground
        view.addSubview(googleLoginButton)
        
        googleLoginButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(48)  // 정사각형 아이콘 버튼
        }
    }
    
    // 구글 로그인 동작
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
            
            // Firebase 인증
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
                
                // 로그인 성공 후 다음 화면으로 이동하거나 UI 업데이트
                DispatchQueue.main.async {
                    self?.handleLoginSuccess()
                }
            }
        }
    }
    
    private func handleLoginSuccess() {
        // 로그인 성공 후 처리할 작업
        let alert = UIAlertController(title: "로그인 성공", message: "Google 로그인이 완료되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
