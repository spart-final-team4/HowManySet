//
//  OnboardingView.swift
//  HowManySet
//
//  Created by GO on 6/13/25.
//

import UIKit
import SnapKit
import Then

/**
 온보딩(앱 첫 실행 시 사용자에게 기능 및 안내를 제공하는) 화면의 View 레이아웃을 담당하는 클래스.

 - 주요 UI 구성:
    - 오른쪽 상단 닫기(X) 버튼
    - 중앙 상단 타이틀 및 서브타이틀 라벨
    - 중앙 이미지 뷰(온보딩 안내 이미지)
    - 이미지 하단 페이지 인디케이터(UIPageControl)
    - 하단 "다음"/"시작하기" 버튼

 - 특징:
    - SnapKit을 이용한 오토레이아웃 적용
    - Then 라이브러리로 UI 요소 선언 및 속성 초기화
    - 배경색, 버튼 컬러 등은 Asset Catalog의 명명 규칙을 따름
    - MVVM 구조에서 View 역할만 담당하며, 상태/이벤트 처리는 ViewController 또는 ViewModel에서 수행
    - iPhone SE (375pt 이하) 화면 크기 대응

 - 사용 예시:
    ```
    let onboardingView = OnboardingView()
    // ViewController에서 addSubview 및 레이아웃 설정 후 사용
    ```
 */
final class OnboardingView: UIView {
    
    // MARK: - SE3 대응 (375 x 667 pt)
    private let customInset: CGFloat = UIScreen.main.bounds.width <= 375 ? 16 : 20
    private let imageHeightMultiplier: CGFloat = UIScreen.main.bounds.width <= 375 ? 1.0 : 1.3
    
    /// 오른쪽 상단 닫기(X) 버튼. 온보딩 화면을 종료할 때 사용.
    let closeButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .white
        $0.contentHorizontalAlignment = .right
        $0.contentVerticalAlignment = .top
    }
 
    /// 온보딩 안내 타이틀 라벨. 중앙 상단에 위치.
    let titleLabel = UILabel().then {
        $0.font = .pretendard(size: 16, weight: .regular)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    /// 온보딩 안내 서브타이틀 라벨. 타이틀 하단에 위치.
    let subTitleLabel = UILabel().then {
        $0.font = .pretendard(size: 20, weight: .bold)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    /// 온보딩 안내 이미지를 표시하는 이미지 뷰. 중앙에 배치.
    let centerImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    /// centerImage와 nextButton 중앙에 pageIndicator 배치를 위한 spacerView
    let spacerView = UIView()
    
    /// 온보딩 진행 상황을 표시하는 페이지 인디케이터(UIPageControl).
    let pageIndicator = UIPageControl().then {
        $0.numberOfPages = 5
        $0.currentPage = 0
        $0.pageIndicatorTintColor = UIColor(white: 1, alpha: 0.2)
        $0.currentPageIndicatorTintColor = UIColor.white
        $0.isUserInteractionEnabled = false
    }

    /// 하단 "다음"/"시작하기" 버튼. 온보딩 단계 이동 또는 완료 시 사용.
    let nextButton = UIButton(type: .system).then {
        $0.setTitle("다음", for: .normal)
        $0.titleLabel?.font = .pretendard(size: 20, weight: .bold)
        $0.backgroundColor = UIColor(named: "brand")
        $0.setTitleColor(.black, for: .normal)
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    // MARK: - Init
    /**
     온보딩 뷰를 초기화하고 UI 요소를 배치합니다.
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OnboardingView {
    /// 전체 UI 구성(색상, 계층, 제약조건) 설정
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    /// 배경색 등 Appearance 설정
    func setAppearance() {
        self.backgroundColor = .background
    }
    
    /// 서브뷰 계층 구조 설정
    func setViewHierarchy() {
        self.addSubviews(closeButton, titleLabel, subTitleLabel, centerImageView, spacerView, pageIndicator, nextButton)
    }
    
    /// SnapKit을 활용한 오토레이아웃 제약조건 설정
    func setConstraints() {
        closeButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(12)
            $0.trailing.equalToSuperview().inset(customInset)
            $0.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(56)
            $0.leading.trailing.equalToSuperview().inset(customInset)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(customInset)
        }
        
        centerImageView.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(45)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(customInset)
            $0.height.equalTo(centerImageView.snp.width).multipliedBy(imageHeightMultiplier)
        }
        
        spacerView.snp.makeConstraints {
            $0.top.equalTo(centerImageView.snp.bottom)
            $0.bottom.equalTo(nextButton.snp.top)
            $0.centerX.equalToSuperview()
        }

        pageIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(spacerView.snp.centerY)
            $0.height.equalTo(16)
        }
        
        nextButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(customInset)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(32)
            $0.height.equalTo(56)
        }
    }
}
