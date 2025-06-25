//
//  EditExcerciseFooterView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/16/25.
//

import UIKit
import SnapKit
import Then
import RxCocoa
import RxSwift

/// 운동 루틴 편집 화면 하단에 위치하는 푸터 뷰입니다.
///
/// 두 개의 주요 액션 버튼을 포함합니다:
/// - `운동 추가` 버튼 (`addExcerciseButton`)
/// - `루틴 저장` 버튼 (`saveRoutineButton`)
///
/// RxCocoa를 활용해 버튼 탭 이벤트를 외부로 전달합니다.
final class EditExcerciseFooterView: UIStackView {
    
    /// '운동 추가' 버튼이 탭되었을 때 이벤트를 방출하는 Relay입니다.
    private(set) var addExcerciseButtonTapped = PublishRelay<Void>()
    
    /// '루틴 저장' 버튼이 탭되었을 때 이벤트를 방출하는 Relay입니다.
    private(set) var saveRoutineButtonTapped = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    
    /// 운동 추가 버튼 - 브랜드색 스타일
    private let addExcerciseButton = UIButton().then {
        $0.setTitle("운동 추가", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        $0.setTitleColor(.background, for: .normal)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.backgroundColor = .brand
    }
    
    /// 루틴 저장 버튼 - 흰색 스타일
    private let saveRoutineButton = UIButton().then {
        $0.setTitle("루틴 저장", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        $0.setTitleColor(.background, for: .normal)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.backgroundColor = .white
    }
    
    /// 기본 생성자 - 수평 스택뷰로 구성 및 UI 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        distribution = .fillEqually
        spacing = 12
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        setupUI()
        bind()
    }
    
    /// 스토리보드 사용 방지
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 버튼에 대한 Rx 바인딩 설정
    private func bind() {
        addExcerciseButton.rx.tap
            .bind(to: addExcerciseButtonTapped)
            .disposed(by: disposeBag)
        
        saveRoutineButton.rx.tap
            .bind(to: saveRoutineButtonTapped)
            .disposed(by: disposeBag)
    }
}

// MARK: - UI 구성 관련 메서드
private extension EditExcerciseFooterView {
    
    /// UI 초기화 메서드 - 뷰 계층 및 외형 설정
    func setupUI() {
        setViewHierarchy()
        setAppearance()
    }
    
    /// 외형 스타일 설정 (배경색 등)
    func setAppearance() {
        self.backgroundColor = .background
    }
    
    /// 스택뷰 내 하위 버튼 추가
    func setViewHierarchy() {
        self.addArrangedSubviews(saveRoutineButton, addExcerciseButton)
    }
}

