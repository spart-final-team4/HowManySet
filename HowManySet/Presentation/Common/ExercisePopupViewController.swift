//
//  ExercisePopupViewController.swift
//  HowManySet
//
//  Created by 정근호 on 6/22/25.
//

import UIKit
import Then
import SnapKit

/// 운종 중 사용자가 직접 운동을 종료하거나, 모든 운동을 완료했을 시 보여주는 팝업
/// - 제목, 내용, 확인 버튼 텍스트를 설정할 수 있으며,
///   확인 버튼 클릭 시 클로저 기반 액션을 실행할 수 있습니다.
/// - 간단한 알림창 또는 확인용 팝업으로 사용됩니다.
final class ExercisePopupViewController: UIViewController {
    
    /// 팝업 내용을 수직으로 정렬하는 스택 뷰
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.backgroundColor = .bottomSheetBG
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        $0.distribution = .fillProportionally
        $0.layer.cornerRadius = 20
    }
    
    /// 팝업 상단에 표시될 제목 레이블
    private let titleLabel = UILabel().then {
        $0.font = .pretendard(size: 18, weight: .semibold)
        $0.textColor = .white
        $0.adjustsFontSizeToFitWidth = true
    }
    
    /// 팝업 본문에 표시될 설명 레이블
    private let contentLabel = UILabel().then {
        $0.font = .pretendard(size: 16, weight: .regular)
        $0.numberOfLines = 0
        $0.textColor = .grey3
        $0.adjustsFontSizeToFitWidth = true
    }
    
    private let buttonHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }
    
    // 왼쪽 버튼 - 취소
    private let leftButton = UIButton().then {
        $0.setTitleColor(.grey1, for: .normal)
        $0.setTitle(String(localized: "취소"), for: .normal)
        $0.titleLabel?.adjustsFontSizeToFitWidth = true
        $0.backgroundColor = .grey5
        $0.layer.cornerRadius = 12
        $0.addTarget(self, action: #selector(didTapLeftButton), for: .touchUpInside)
        $0.isHidden = true
    }
    
    /// 오른쪽 버튼 - 운동 종료
    private let rightButton = UIButton().then {
        $0.setTitleColor(.grey1, for: .normal)
        $0.titleLabel?.adjustsFontSizeToFitWidth = true
        $0.backgroundColor = .grey5
        $0.layer.cornerRadius = 12
        $0.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)
    }
    
    /// 클릭 시 실행할 액션
    private var nextAction: (() -> Void)?
    private var cancelAction: (() -> Void?)?
    
    private var hasTwoButtons = false
    
    override func viewDidLoad() {
        setupUI()
    }
    
    /// 팝업 초기화 메서드
    /// - Parameters:
    ///   - title: 제목 텍스트
    ///   - content: 내용 텍스트
    ///   - leftButtonText: 왼쪽 버튼 텍스트
    ///   - rightButtonText: 오른쪽 버튼 텍스트
    ///   - nextAction: 운동 종료 버튼 클릭 시 실행할 클로저
    ///   - cancelAction: 계속 하기 버튼 클릭 시 실행할 클로저
    convenience init(title: String,
                     content: String = "",
                     rightButtonText: String,
                     rightButtonTitleColor: UIColor,
                     rightButtonBackgroundColor: UIColor,
                     nextAction: @escaping () -> Void,
                     cancelAction: @escaping () -> Void?,
                     hasTwoButtons: Bool
    ) {
        self.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overCurrentContext
        self.titleLabel.text = title
        self.contentLabel.text = content
        self.rightButton.setTitle(rightButtonText, for: .normal)
        self.rightButton.setTitleColor(rightButtonTitleColor, for: .normal)
        self.rightButton.backgroundColor = rightButtonBackgroundColor
//        self.rightButton.setTitle(rightButtonText, for: .normal)
        self.nextAction = nextAction
        self.cancelAction = cancelAction
        self.hasTwoButtons = hasTwoButtons
    }
    
    /// 계속 하기 클릭 시
    @objc private func didTapLeftButton() {
        leftButton.animateTap { [weak self] in
            guard let self else { return }
            self.cancelAction?()
            self.dismiss(animated: true)
        }
    }
    
    /// 왼쪽 운동 종료 버튼 클릭 시
    @objc private func didTapRightButton() {
        rightButton.animateTap { [weak self] in
            guard let self else { return }
            self.nextAction?()
            self.dismiss(animated: true)
        }
    }
}

private extension ExercisePopupViewController {
    
    /// UI 구성 전체 수행
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
        
        if hasTwoButtons {
            leftButton.isHidden = false
        }
    }

    /// 뷰 배경 설정
    func setAppearance() {
        view.backgroundColor = .black.withAlphaComponent(0.3)
    }

    /// 뷰 계층 구성
    func setViewHierarchy() {
        view.addSubviews(stackView)
        stackView.addArrangedSubviews(
            titleLabel,
            contentLabel,
            buttonHStackView
        )
        buttonHStackView.addArrangedSubviews(
            leftButton,
            rightButton
        )
    }

    /// 제약조건 설정
    func setConstraints() {
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.height.greaterThanOrEqualToSuperview().multipliedBy(0.22)
        }
        
        [leftButton, rightButton].forEach {
            $0.snp.makeConstraints {
                if hasTwoButtons {
                    $0.width.equalTo(stackView).multipliedBy(0.4)
                }
                $0.height.equalTo(stackView).multipliedBy(0.28)
            }
        }
    }
}

