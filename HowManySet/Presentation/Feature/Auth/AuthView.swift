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
        $0.contentMode = .scaleAspectFit
    }

    /// 카카오 로그인 버튼 - Configuration 사용
    let kakaoLoginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "카카오로 시작하기"
        config.baseBackgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0)
        config.baseForegroundColor = .black
        config.image = UIImage(named: "Kakao")
        config.imagePadding = 8
        config.imagePlacement = .leading
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return button
    }()

    let googleLoginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black
        config.title = "Google로 로그인"
        config.image = UIImage(named: "Google")
        config.imagePadding = 8
        config.imagePlacement = .leading
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return button
    }()

    let appleLoginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black).then {
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }

    /// 비회원 시작 버튼 - 텍스트 링크 스타일
    let anonymousLoginButton: UIButton = {
        let button = UIButton(type: .system)
        let title = "비회원으로 시작하기"
        let attributed = NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .regular),
                .foregroundColor: UIColor.systemGray,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        button.setAttributedTitle(attributed, for: .normal)
        button.contentHorizontalAlignment = .center
        button.backgroundColor = .clear
        return button
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        
        /// 카카오 uid 관련 버그 발생 (마이너 업데이트에 수정 예정)
        kakaoLoginButton.isHidden = true
        kakaoLoginButton.isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    private func setupLayout() {
        backgroundColor = .background
        addSubviews(logoView, kakaoLoginButton, googleLoginButton, appleLoginButton, anonymousLoginButton)

        logoView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(160)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(215)
            $0.height.equalTo(75)
        }

        anonymousLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-24)
            $0.height.equalTo(24)
        }

        appleLoginButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(56)
            $0.bottom.equalTo(anonymousLoginButton.snp.top).offset(-16)
        }

        googleLoginButton.snp.makeConstraints {
            $0.left.right.height.equalTo(appleLoginButton)
            $0.bottom.equalTo(appleLoginButton.snp.top).offset(-16)
        }

        kakaoLoginButton.snp.makeConstraints {
            $0.left.right.height.equalTo(appleLoginButton)
            $0.bottom.equalTo(googleLoginButton.snp.top).offset(-16)
        }
    }
}
