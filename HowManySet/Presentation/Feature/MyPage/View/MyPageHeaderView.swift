//
//  MyPageHeaderView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class MyPageHeaderView: UIView {
    
    private let usernameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 36, weight: .regular)
        $0.numberOfLines = 0
        $0.text = "비회원"
        $0.textColor = .white
    }
    
    private let userloginButton = UIButton().then {
        $0.setTitle(" 회원전환 ", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        $0.clipsToBounds = true
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 12
        $0.backgroundColor = .cardContentBG
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension MyPageHeaderView {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.backgroundColor = .bsInputFieldBG
    }
    
    func setViewHierarchy() {
        self.addSubviews(usernameLabel, userloginButton)
    }
    
    func setConstraints() {
        usernameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
        userloginButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(10)
        }
    }
}
