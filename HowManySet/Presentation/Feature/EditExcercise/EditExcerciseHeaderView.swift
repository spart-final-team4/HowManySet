//
//  EditExcerciseHeaderView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/15/25.
//

import UIKit
import SnapKit
import Then
import RxCocoa
import RxSwift

/// 운동 이름을 입력받는 화면 상단 헤더 뷰입니다.
///
/// `UILabel`과 `UITextField`를 포함하며, 사용자가 운동명을 입력할 수 있도록 구성되어 있습니다.
final class EditExcerciseHeaderView: UIView {
    
    private let disposeBag = DisposeBag()
    private(set) var exerciseNameRelay = BehaviorRelay<String>(value: "")
    
    /// 운동명 입력 안내 텍스트를 보여주는 라벨입니다.
    private let titleLabel = UILabel().then {
        $0.text = "운동명을 입력해주세요"
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textColor = .textSecondary
    }
    
    /// 사용자가 운동명을 입력할 수 있는 텍스트 필드입니다.
    ///
    /// 좌측에 패딩이 들어가며, 둥근 테두리와 배경색이 적용되어 있습니다.
    private let exerciseNameTextField = UITextField().then {
        $0.placeholder = "예)벤치프레스, 체스트 프레스"
        $0.backgroundColor = .bottomSheetBG
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: $0.frame.height))
        $0.leftView = paddingView
        $0.leftViewMode = .always
    }
    
    /// 코드로 초기화할 때 사용되는 이니셜라이저입니다.
    ///
    /// - Parameter frame: 뷰의 프레임.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
    }
    
    /// 스토리보드나 XIB를 통한 초기화는 지원하지 않습니다.
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Methods

private extension EditExcerciseHeaderView {
    
    /// UI를 구성하는 전체 흐름을 정의합니다.
    func setupUI() {
        setViewHierarchy()
        setConstraints()
        setAppearance()
        bind()
    }
    
    func bind() {
        exerciseNameTextField.rx.text
            .compactMap{ $0 }
            .distinctUntilChanged()
            .bind(to: exerciseNameRelay)
            .disposed(by: disposeBag)
    }
    
    /// 뷰의 외형(배경색 등)을 설정합니다.
    func setAppearance() {
        self.backgroundColor = .background
    }
    
    /// 서브뷰들을 계층에 추가합니다.
    func setViewHierarchy() {
        self.addSubviews(titleLabel, exerciseNameTextField)
    }
    
    /// 각 서브뷰에 대한 오토레이아웃 제약을 설정합니다.
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(20)
            $0.top.equalTo(self.safeAreaLayoutGuide).inset(8)
        }
        exerciseNameTextField.snp.makeConstraints {
            $0.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.height.equalTo(56)
        }
    }
}
