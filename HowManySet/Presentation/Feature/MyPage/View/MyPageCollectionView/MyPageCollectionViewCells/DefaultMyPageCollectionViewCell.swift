//
//  MyPageCollectionViewCell.swift
//  HowManySet
//
//  Created by MJ Dev on 6/10/25.
//

import UIKit
import Then

/// 마이페이지에서 기본 항목을 표시하는 컬렉션뷰 셀
/// - 항목 제목을 좌측에 표시함
final class DefaultMyPageCollectionViewCell: UICollectionViewCell {
    
    /// 셀 재사용 식별자
    static var identifier: String {
        return String(describing: self)
    }
    
    /// 항목 제목을 표시하는 라벨
    private let titleLabel = UILabel().then {
        $0.font = .pretendard(size: 18, weight: .regular)
        $0.textColor = .white
        $0.numberOfLines = 0
    }

    /// 업데이트 예정임을 나타내는 label
    private let statusLabel = UILabel().then {
        $0.font = .pretendard(size: 14, weight: .regular)
        $0.textColor = .dbTypo
        $0.text = "업데이트 예정"
        $0.isHidden = true
    }

    /// 셀 초기화 메서드
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    /// 스토리보드 사용 불가 처리
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 셀 구성 메서드
    /// - Parameter model: MyPageCellModel (제목 포함)
    func configure(model: MyPageCellModel) {
        self.titleLabel.text = model.title

        if model.title == "언어 변경" {
            titleLabel.textColor = .dbTypo
            statusLabel.isHidden = false
            isUserInteractionEnabled = false
        }
    }
}

private extension DefaultMyPageCollectionViewCell {
    
    /// UI 초기 설정 메서드
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    /// 셀 배경색 및 외형 설정
    func setAppearance() {
        self.backgroundColor = .background
    }
    
    /// 뷰 계층 구성
    func setViewHierarchy() {
        self.addSubviews(titleLabel, statusLabel)
    }
    
    /// 오토레이아웃 제약 조건 설정
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }

        statusLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }
}
