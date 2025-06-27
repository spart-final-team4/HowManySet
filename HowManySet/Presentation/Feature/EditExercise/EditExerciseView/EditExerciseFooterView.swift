//
//  AddExcerciseFooterView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/26/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

final class EditExerciseFooterView: UIView {
    
    private let disposeBag = DisposeBag()
    private(set) var saveExcerciseButtonRelay: PublishRelay<Void> = .init()
    
    private let saveExcerciseButton = UIButton().then {
        $0.setTitle("저장하기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        $0.setTitleColor(.background, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    /// 스토리보드 사용 방지
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - UI 구성 관련 메서드
private extension EditExerciseFooterView {
    
    /// UI 초기화 메서드 - 뷰 계층 및 외형 설정
    func setupUI() {
        setViewHierarchy()
        setAppearance()
        bind()
        setConstraints()
    }
    
    func bind() {
        saveExcerciseButton.rx.tap
            .bind(to: saveExcerciseButtonRelay)
            .disposed(by: disposeBag)
    }
    
    /// 외형 스타일 설정 (배경색 등)
    func setAppearance() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
        self.backgroundColor = .brand
    }
    
    /// 스택뷰 내 하위 버튼 추가
    func setViewHierarchy() {
        self.addSubviews(saveExcerciseButton)
    }
    
    func setConstraints() {
        saveExcerciseButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

