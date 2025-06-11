//
//  VersionMyPageCollectionViewCell.swift
//  HowManySet
//
//  Created by MJ Dev on 6/11/25.
//

import UIKit
import Then
import SnapKit

/// 마이페이지에서 버전 정보를 표시하는 셀
/// - 좌측에는 항목 제목, 우측에는 버전 문자열을 표시함
final class VersionMyPageCollectionViewCell: UICollectionViewCell {
    
    /// 셀 식별자 (재사용을 위해 사용)
    static var identifier: String {
        return String(describing: self)
    }
    
    /// 항목 제목 라벨
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .regular)
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    
    /// 버전 정보 라벨
    private let versionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .textSecondary
        $0.numberOfLines = 0
    }
    
    /// 셀 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    /// 스토리보드 초기화 방지
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 셀 구성 메서드
    /// - Parameter model: MyPageCellModel (타이틀과 버전 정보 포함)
    func configure(model: MyPageCellModel) {
        self.titleLabel.text = model.title
        self.versionLabel.text = model.version
    }
}

extension VersionMyPageCollectionViewCell {
    
    /// UI 전체 설정을 구성하는 메서드
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    /// 외형 설정 (배경색 등)
    func setAppearance() {
        self.backgroundColor = .bsInputFieldBG
    }
    
    /// 뷰 계층 구성
    func setViewHierarchy() {
        self.addSubviews(titleLabel, versionLabel)
    }
    
    /// 오토레이아웃 제약 설정
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        versionLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }
}
