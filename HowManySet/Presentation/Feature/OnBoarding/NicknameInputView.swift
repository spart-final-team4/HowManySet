//
//  NicknameInputView.swift
//  HowManySet
//
//  Created by GO on 6/13/25.
//

import UIKit
import SnapKit
import Then

final class NicknameInputView: UIView {
    
    private let titleLabel = UILabel().then() {
        $0.text = "닉네임을 적어주세요"
        $0.font = .boldSystemFont(ofSize: 24)
        $0.textColor = .white
        $0.textAlignment = .left
    }
    
    private let nicknameTextField = UITextField().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .white
        $0.backgroundColor = .darkGray
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.attributedPlaceholder = NSAttributedString(
            string: "한글, 영문 2~8자",
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.leftViewMode = .always
    }
    
    // 일단 public 추후 수정 예정
    let nextButton = UIButton().then {
        $0.setTitle("다음", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.isEnabled = false

        // 비활성화 상태 스타일
        $0.backgroundColor = .darkGray
        $0.setTitleColor(.lightGray, for: .normal)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Button 활성화/비활성화 (기본 비활성화) - ViewModel로 옮길 예정
extension NicknameInputView {
    
}

// MARK: - UI
private extension NicknameInputView {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.backgroundColor = UIColor(named: "Background")
    }
    
    func setViewHierarchy() {
        self.addSubviews(titleLabel, nicknameTextField, nextButton)
    }
    
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(32)
            $0.directionalHorizontalEdges.equalToSuperview().inset(20)
        }
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.directionalHorizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        nextButton.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(24)
            $0.height.equalTo(52)
        }
    }
}
