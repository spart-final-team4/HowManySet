//
//  MyPageView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/10/25.
//

import UIKit
import SnapKit
import Then

final class MyPageView: UIView {
    
    private let headerView = MyPageHeaderView()
    private let collectionView = MyPageCollectionView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


private extension MyPageView {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.backgroundColor = .bsInputFieldBG
    }
    
    func setViewHierarchy() {
        self.addSubviews(headerView, collectionView)
    }
    
    func setConstraints() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
