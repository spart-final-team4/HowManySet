//
//  MyPageCollectionHeaderView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/10/25.
//

import UIKit
import Then
import SnapKit

/// 마이페이지 컬렉션 뷰의 섹션 헤더 뷰
/// - 섹션의 제목을 표시함
final class MyPageCollectionHeaderView: UICollectionReusableView {
    
    /// 셀 식별자 (재사용 등록에 사용)
    static var identifier: String {
        return String(describing: self)
    }
    
    /// 섹션 제목 라벨
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .systemGray3
    }
    
    /// 초기화 메서드
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    /// 스토리보드 사용 방지
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 헤더 뷰에 데이터 모델을 적용하는 메서드
    /// - Parameter model: MyPageSectionModel (섹션 제목 포함)
    func configure(model: MyPageSectionModel) {
        self.titleLabel.text = model.title
    }
}

private extension MyPageCollectionHeaderView {
    
    /// UI 설정을 일괄 수행하는 메서드
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    /// 외형 설정 (배경색 등)
    func setAppearance() {
        self.backgroundColor = .background
    }
    
    /// 뷰 계층 구조 구성
    func setViewHierarchy() {
        self.addSubviews(titleLabel)
    }
    
    /// 오토레이아웃 제약 설정
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
    }
}
