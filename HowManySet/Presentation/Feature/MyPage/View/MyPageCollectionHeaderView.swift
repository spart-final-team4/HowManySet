//
//  MyPageCollectionHeaderView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/10/25.
//

import UIKit
import Then
import SnapKit

final class MyPageCollectionHeaderView: UICollectionReusableView {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .systemGray3
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: MyPageSectionModel) {
        self.titleLabel.text = model.title
    }
}

private extension MyPageCollectionHeaderView {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.backgroundColor = .bsInputFieldBG
    }
    
    func setViewHierarchy() {
        self.addSubviews(titleLabel)
    }
    
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
    }
}
