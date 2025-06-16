//
//  OnboardingView.swift
//  HowManySet
//
//  Created by GO on 6/13/25.
//

import UIKit
import SnapKit
import Then

final class OnboardingView: UIView {
    
    // MARK: - UI 요소
    let closeButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .white
        $0.contentHorizontalAlignment = .right
        $0.contentVerticalAlignment = .top
    }
 
    let titleLabel = UILabel().then {
        $0.text = "운동 이름부터 세트 수까지"
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    let subTitleLabel = UILabel().then {
        $0.text = "내 루틴에 맞게 직접 설정해보세요"
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    // 중앙부 이미지
    let centerImageView = UIImageView().then {
        $0.image = UIImage(named: "onboarding_sample") // 실제 이미지명으로 교체
        $0.contentMode = .scaleAspectFit
    }
    
    // 인디케이터 (UIPageControl)
    let pageIndicator = UIPageControl().then {
        $0.numberOfPages = 5
        $0.currentPage = 0
        $0.pageIndicatorTintColor = UIColor(white: 1, alpha: 0.2)
        $0.currentPageIndicatorTintColor = UIColor.white
        $0.isUserInteractionEnabled = false
    }

    let nextButton = UIButton(type: .system).then {
        $0.setTitle("다음", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        $0.backgroundColor = UIColor(named: "brand") ?? UIColor.systemGreen
        $0.setTitleColor(.black, for: .normal)
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OnboardingView {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.backgroundColor = UIColor(named: "Background")
    }
    
    func setViewHierarchy() {
        self.addSubviews(closeButton, titleLabel, subTitleLabel, centerImageView, pageIndicator, nextButton)
    }
    
    func setConstraints() {
        closeButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(12)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(56)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        centerImageView.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(260)
            $0.height.equalTo(520)
        }
        
        pageIndicator.snp.makeConstraints {
            $0.top.equalTo(centerImageView.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        nextButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(32)
            $0.height.equalTo(56)
        }
    }
}
