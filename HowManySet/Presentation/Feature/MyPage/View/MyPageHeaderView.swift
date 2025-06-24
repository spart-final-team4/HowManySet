//
//  MyPageHeaderView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/10/25.
//

import UIKit
import SnapKit
import Then

/// 마이페이지 상단에 사용자 이름(또는 비회원)을 표시하는 헤더 뷰
/// - 사용자 식별 또는 상태 표시 용도로 사용됩니다.
final class MyPageHeaderView: UIView {
    
    /// 사용자 이름 또는 상태(예: 비회원)를 표시하는 레이블
    let usernameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 36, weight: .regular)
        $0.numberOfLines = 0
        $0.text = "비회원" // 기본값
        $0.textColor = .white
    }
    
    /// 코드 기반 초기화 메서드
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    /// 스토리보드 사용 불가 (명시적 제한)
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MyPageHeaderView {
    
    /// UI 설정을 위한 메서드 모음 호출
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    /// 배경색 등 뷰의 외형 설정
    func setAppearance() {
        self.backgroundColor = .background
    }
    
    /// 서브뷰(요소) 계층 구성
    func setViewHierarchy() {
        self.addSubviews(usernameLabel)
    }
    
    /// 오토레이아웃 제약 설정
    func setConstraints() {
        usernameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
    }
}
