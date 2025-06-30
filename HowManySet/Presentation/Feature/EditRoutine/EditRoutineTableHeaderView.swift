//
//  EditRoutineTableHeaderView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/16/25.
//

import UIKit
import SnapKit
import Then

/// 운동 루틴 편집 화면에서 섹션의 헤더로 사용되는 뷰
/// - 기능: 루틴 이름을 섹션 헤더에 표시
final class EditRoutineTableHeaderView: UITableViewHeaderFooterView {
    
    /// 셀 재사용을 위한 identifier
    static var identifier: String {
        return String(describing: self)
    }
    
    /// 섹션 제목을 표시하는 라벨
    private let titleLabel = UILabel().then {
        $0.font = .pretendard(size: 36, weight: .regular)
        $0.textColor = .white
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
    
    /// 섹션 제목을 설정하는 메서드
    /// - Parameter titleText: 표시할 제목 문자열
    func configure(with titleText: String) {
        self.titleLabel.text = titleText
    }
}

// MARK: - Private UI 설정
private extension EditRoutineTableHeaderView {
    
    /// UI 초기화 순서
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    /// 배경 설정
    func setAppearance() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .background
        self.backgroundView = backgroundView
    }
    
    /// 서브뷰 계층 구조 구성
    func setViewHierarchy() {
        self.addSubviews(titleLabel)
    }
    
    /// 오토레이아웃 제약 설정
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().offset(14)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}
