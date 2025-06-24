//
//  AuthViewController.swift
//  HowManySet
//
//  Created by GO on 6/3/25.
//

import UIKit
import ReactorKit
import AuthenticationServices
import RxSwift
import RxCocoa
import CryptoKit

final class AuthViewController: UIViewController, View {
    typealias Reactor = AuthViewReactor

    private let mainView = AuthView()
    private let coordinator: AuthCoordinatorProtocol
    var disposeBag = DisposeBag()
    
    // ASAuthorizationController를 강한 참조로 유지
    private var appleAuthController: ASAuthorizationController?
    // nonce를 인스턴스 변수로 저장
    private var currentNonce: String?

    init(reactor: AuthViewReactor, coordinator: AuthCoordinatorProtocol) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() { view = mainView }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func bind(reactor: AuthViewReactor) {
        mainView.kakaoLoginButton.rx.tap
            .map { Reactor.Action.tapKakaoLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.googleLoginButton.rx.tap
            .map { Reactor.Action.tapGoogleLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.appleLoginButton.rx.controlEvent(.touchUpInside)
            .bind { [weak self] in self?.startAppleLogin() }
            .disposed(by: disposeBag)
        
        mainView.anonymousLoginButton.rx.tap
            .map { Reactor.Action.tapAnonymousLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state.compactMap { $0.error }
            .subscribe(onNext: { [weak self] error in
                self?.showErrorAlert(error)
            })
            .disposed(by: disposeBag)
    }

    private func startAppleLogin() {
        let provider = ASAuthorizationAppleIDProvider()
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let request = provider.createRequest()
        request.nonce = sha256(nonce)
        request.requestedScopes = [.fullName, .email]

        appleAuthController = ASAuthorizationController(authorizationRequests: [request])
        appleAuthController?.delegate = self
        appleAuthController?.presentationContextProvider = self
        appleAuthController?.performRequests()
    }
}

// MARK: - Alert
extension AuthViewController {
    private func showErrorAlert(_ error: Error) {
        let (title, message) = getSecureErrorMessage(error)
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func getSecureErrorMessage(_ error: Error) -> (title: String, message: String) {
        print("🔴 로그인 오류: \(error.localizedDescription)")
        
        let title = "로그인 실패"
        let message: String
        
        if let nsError = error as NSError? {
            switch nsError.domain {
            case "FIRAuthErrorDomain":
                message = "로그인 정보를 확인해 주세요."
            case NSURLErrorDomain:
                message = "네트워크 연결을 확인해 주세요."
            default:
                message = "일시적인 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요."
            }
        } else {
            message = "일시적인 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요."
        }
        return (title, message)
    }
}

extension AuthViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        defer {
            appleAuthController = nil
            currentNonce = nil
        }
        
        guard let reactor = self.reactor,
              let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityTokenData = appleIDCredential.identityToken,
              let identityTokenString = String(data: identityTokenData, encoding: .utf8),
              let nonce = currentNonce else {
            return
        }
        
        reactor.action.onNext(.tapAppleLogin(idToken: identityTokenString, nonce: nonce))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        appleAuthController = nil
        currentNonce = nil
        showErrorAlert(error)
    }
}

private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
        let randoms = (0..<16).map { _ in UInt8.random(in: 0...255) }
        for random in randoms {
            if remainingLength == 0 { break }
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    return result
}

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.map { String(format: "%02x", $0) }.joined()
}
