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
        let nonce = randomNonceString()
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.nonce = sha256(nonce)
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
        objc_setAssociatedObject(controller, AssociatedNonceKey, nonce, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    private func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "로그인 실패",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension AuthViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let reactor = self.reactor else { return }
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityTokenData = appleIDCredential.identityToken,
           let identityTokenString = String(data: identityTokenData, encoding: .utf8),
           let nonce = objc_getAssociatedObject(controller, &AssociatedNonceKey) as? String {
            reactor.action.onNext(.tapAppleLogin(idToken: identityTokenString, nonce: nonce))
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple 로그인 실패: \(error.localizedDescription)")
        showErrorAlert(error)
    }
}

private var AssociatedNonceKey = UnsafeRawPointer(bitPattern: "apple_login_nonce".hashValue)!

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
