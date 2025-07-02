//
//  EditRoutineTableFooterView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/16/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// 운동 루틴 편집 화면의 푸터 뷰
/// - 기능: 테이블의 마지막에 위치하여 "새 운동 추가" 버튼 역할을 하는 UI를 제공
final class EditRoutineTableFooterView: UITableViewHeaderFooterView {
    
    /// 셀 재사용을 위한 identifier
    static var identifier: String {
        return String(describing: self)
    }
    
    var disposeBag = DisposeBag()
    private(set) var plusExcerciseButtonTapped = PublishRelay<Void>()
    
    /// "새 운동 추가" 텍스트 라벨
    private let plusExcerciseButton = UIButton().then {
        $0.setTitle(String(localized: "새 운동 추가"), for: .normal)
        $0.titleLabel?.font = .pretendard(size: 20, weight: .regular)
        $0.setTitleColor(.white, for: .normal)
    }
    
    // MARK: - Initializer
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(viewCaller: ViewCaller) {
        if case .fromHome = viewCaller {
            plusExcerciseButton.isHidden = true
        }
    }
}

// MARK: - Private UI Setup
private extension EditRoutineTableFooterView {
    
    /// UI 초기 설정을 수행하는 메서드
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
        bind()
    }
    
    func bind() {
        plusExcerciseButton.rx.tap
            .bind(to: plusExcerciseButtonTapped)
            .disposed(by: disposeBag)
    }
    
    /// 배경 색상 및 스타일 설정
    func setAppearance() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .background
        self.backgroundView = backgroundView
    }
    
    /// 서브뷰 계층 구조 설정
    func setViewHierarchy() {
        self.addSubviews(plusExcerciseButton)
    }
    
    /// 오토레이아웃 제약 조건 설정
    func setConstraints() {
        plusExcerciseButton.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(20)
        }
    }
}
