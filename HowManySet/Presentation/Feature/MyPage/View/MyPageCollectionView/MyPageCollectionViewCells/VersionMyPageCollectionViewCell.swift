//
//  VersionMyPageCollectionViewCell.swift
//  HowManySet
//
//  Created by MJ Dev on 6/11/25.
//

import UIKit
import Then
import SnapKit

final class VersionMyPageCollectionViewCell: UICollectionViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .regular)
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    
    private let versionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .textSecondary
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: MyPageCellModel) {
        self.titleLabel.text = model.title
        self.versionLabel.text = model.version
    }
}

extension VersionMyPageCollectionViewCell {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.backgroundColor = .bsInputFieldBG
    }
    
    func setViewHierarchy() {
        self.addSubviews(titleLabel, versionLabel)
    }
    
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
