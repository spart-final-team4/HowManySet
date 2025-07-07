//
//  OnboardingPageControlView.swift
//  HowManySet
//
//  Created by GO on 7/7/25.
//

import UIKit
import SnapKit
import Then

final class OnboardingPageControlView: UIView {

    private let titleLabel = UILabel().then {
        $0.font = .pretendard(size: 16, weight: .regular)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = .pretendard(size: 20, weight: .bold)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private let centerImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    init(pageData: OnBoardingViewReactor.OnboardingPageData) {
        super.init(frame: .zero)
        setupUI()
        configure(with: pageData)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(with data: OnBoardingViewReactor.OnboardingPageData) {
        titleLabel.text = data.title
        subTitleLabel.text = data.subtitle
        centerImageView.image = UIImage(named: data.imageName)
    }
}

private extension OnboardingPageControlView {
    
    /// 전체 UI 구성(색상, 계층, 제약조건)을 설정합니다.
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        addSubviews(titleLabel, subTitleLabel, centerImageView)
    }
    
    func setConstraints() {
        let customInset: CGFloat = UIScreen.main.bounds.width <= 375 ? 16 : 20
        let imageHeightMultiplier: CGFloat = UIScreen.main.bounds.width <= 375 ? 1.0 : 1.3
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview() // 부모 뷰(StackView) 내에서의 상대적 위치
            $0.leading.trailing.equalToSuperview().inset(customInset)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(customInset)
        }
        
        centerImageView.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(45)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().inset(customInset)
            $0.height.equalTo(centerImageView.snp.width).multipliedBy(imageHeightMultiplier)
        }
    }
}
