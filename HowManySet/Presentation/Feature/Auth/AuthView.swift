//
//  AuthView.swift
//  HowManySet
//
//  Created by GO on 6/11/25.
//

import UIKit
import SnapKit
import Then
import AuthenticationServices

final class AuthView: UIView {

    // MARK: - UI 요소
    private let logoView = UIImageView().then {
        $0.image = UIImage(named: "MainIcon")
        $0.backgroundColor = .clear
    }

    private let logoTitle = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.attributedText = NSAttributedString(
            string: "HOW MANY SET",
            attributes: [.kern: 2.0]
        )
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowRadius = 2
    }

    let appleLoginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)

    let googleLoginButton: UIButton = {
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

    let kakaoLoginButton = UIButton(type: .system).then {
        $0.setTitle("  카카오로 시작하기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        $0.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0)
        $0.layer.cornerRadius = 12
        $0.setImage(UIImage(named: "Kakao"), for: .normal)
        $0.tintColor = .black
        $0.contentHorizontalAlignment = .center
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupLayout() {
        addSubviews(logoView, logoTitle, kakaoLoginButton, googleLoginButton, appleLoginButton)

        logoView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(220)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(215)
            $0.height.equalTo(75)
        }
        logoTitle.snp.makeConstraints {
            $0.top.equalTo(logoView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
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
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(32)
        }
    }
}
