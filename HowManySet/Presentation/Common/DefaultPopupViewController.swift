//
//  DefaultPopupViewController.swift
//  HowManySet
//
//  Created by MJ Dev on 6/12/25.
//

import UIKit
import Then
import SnapKit

import UIKit
import Then
import SnapKit

/// 기본 팝업 뷰 컨트롤러
/// - 제목, 내용, 확인 버튼 텍스트를 설정할 수 있으며,
///   확인 버튼 클릭 시 클로저 기반 액션을 실행할 수 있습니다.
/// - 간단한 알림창 또는 확인용 팝업으로 사용됩니다.
final class DefaultPopupViewController: UIViewController {
    
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
        $0.font = .systemFont(ofSize: 18, weight: .regular)
        $0.textColor = .error
    }
    
    /// 팝업 본문에 표시될 설명 레이블
    private let contentLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.numberOfLines = 0
        $0.textColor = .textTertiary
    }
    
    /// 확인(OK) 버튼 - 텍스트 설정 가능하며, 클릭 시 전달된 클로저 실행
    private let okButton = UIButton().then {
        $0.setTitleColor(.textTertiary, for: .normal)
        $0.backgroundColor = .error
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.addTarget(self, action: #selector(didTapOkButton), for: .touchUpInside)
    }
    
    /// 취소 버튼 - 기본 텍스트 "취소", 클릭 시 팝업을 닫음
    private let cancelButton = UIButton().then {
        $0.setTitleColor(.textTertiary, for: .normal)
        $0.backgroundColor = .clear
        $0.setTitle("취소", for: .normal)
        $0.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
    }
    
    /// 확인 버튼 클릭 시 실행할 액션
    private var okAction: (() -> Void)?
    
    override func viewDidLoad() {
        setupUI()
    }
    
    /// 팝업 초기화 메서드
    /// - Parameters:
    ///   - title: 제목 텍스트
    ///   - titleTextColor: 제목 텍스트 색
    ///   - content: 내용 텍스트
    ///   - okButtonText: 확인 버튼 텍스트
    ///   - okButtonBackgroundColor: 확인 버튼 배경 색
    ///   - okAction: 확인 버튼 클릭 시 실행할 클로저
    convenience init(title: String,
                     titleTextColor: UIColor = .error,
                     content: String = "",
                     okButtonText: String,
                     okButtonBackgroundColor: UIColor = .error,
                     okAction: @escaping () -> Void) {
        self.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overCurrentContext
        self.titleLabel.text = title
        self.titleLabel.textColor = titleTextColor
        self.contentLabel.text = content
        self.okButton.setTitle(okButtonText, for: .normal)
        self.okButton.backgroundColor = okButtonBackgroundColor
        self.okAction = okAction
    }
    
    /// 확인 버튼 클릭 시 호출되는 메서드
    @objc private func didTapOkButton() {
        okAction?()
        self.dismiss(animated: true)
    }
    
    /// 취소 버튼 클릭 시 팝업 닫기
    @objc private func didTapCancelButton() {
        self.dismiss(animated: true)
    }
}

private extension DefaultPopupViewController {
    
    /// UI 구성 전체 수행
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }

    /// 뷰 배경 설정
    func setAppearance() {
        view.backgroundColor = .black.withAlphaComponent(0.3)
    }

    /// 뷰 계층 구성
    func setViewHierarchy() {
        view.addSubviews(stackView)
        stackView.addArrangedSubviews(titleLabel, contentLabel, okButton, cancelButton)
    }

    /// 제약조건 설정
    func setConstraints() {
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.75)
            $0.height.greaterThanOrEqualToSuperview().multipliedBy(0.2)
        }
    }
}
