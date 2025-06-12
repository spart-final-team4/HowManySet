//
//  MyPageCollectionView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/10/25.
//

import UIKit

/// 마이페이지에 사용되는 커스텀 UICollectionView
/// - 셀 및 헤더 등록, 레이아웃 설정, 데이터소스 및 델리게이트 구현 포함
final class MyPageCollectionView: UICollectionView {
    
    /// 기본 생성자 - 커스텀 레이아웃 및 셀/헤더 등록
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
        setupUI()
    }
    
    /// 스토리보드 사용 방지
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension MyPageCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// 섹션 개수 반환
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return MyPageCollectionViewModel.model.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section >= (MyPageCollectionViewModel.model.count-1) {
            return .zero
        }
        return CGSize(width: UIScreen.main.bounds.width, height: 10)
    }
    
    /// 섹션별 아이템 수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MyPageCollectionViewModel.model[section].cellModel.count
    }
    
    /// 셀 생성 및 구성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 버전 셀인 경우
        if indexPath.section == 1 && indexPath.row == 0 {
            guard let versionCell = collectionView.dequeueReusableCell(withReuseIdentifier: VersionMyPageCollectionViewCell.identifier,
                                                                       for: indexPath) as? VersionMyPageCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            versionCell.configure(model: MyPageCollectionViewModel.model[indexPath.section].cellModel[indexPath.row])
            return versionCell
        } else {
            // 기본 셀
            guard let defaultCell = collectionView.dequeueReusableCell(withReuseIdentifier: DefaultMyPageCollectionViewCell.identifier,
                                                                for: indexPath) as? DefaultMyPageCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            defaultCell.configure(model: MyPageCollectionViewModel.model[indexPath.section].cellModel[indexPath.row])
            return defaultCell
        }
    }
    
    /// 섹션 헤더 뷰 설정
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                               withReuseIdentifier: MyPageCollectionHeaderView.identifier,
                                                                               for: indexPath) as? MyPageCollectionHeaderView
            else { return UICollectionReusableView() }
            header.configure(model: MyPageCollectionViewModel.model[indexPath.section])
            return header
        case UICollectionView.elementKindSectionFooter:
            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                                               withReuseIdentifier: MyPageCollectionFooterView.identifier,
                                                                               for: indexPath) as? MyPageCollectionFooterView
            else { return UICollectionReusableView() }
            return footer
        default:
            return UICollectionReusableView()
        }
    }
}

private extension MyPageCollectionView {
    func setupUI() {
        setLayout()
        setAppearance()
        setDelegates()
        registerViews()
    }
    func setAppearance() {
        self.backgroundColor = .background
    }
    /// 컬렉션 뷰 레이아웃 설정
    func setLayout() {
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 40)
        layout.minimumLineSpacing = 0
        
        self.collectionViewLayout = layout
        self.reloadData()
    }
    func setDelegates() {
        delegate = self
        dataSource = self
    }
    func registerViews() {
        // 기본 셀 등록
        self.register(DefaultMyPageCollectionViewCell.self,
                      forCellWithReuseIdentifier: DefaultMyPageCollectionViewCell.identifier)
        
        // 버전 정보 셀 등록
        self.register(VersionMyPageCollectionViewCell.self,
                      forCellWithReuseIdentifier: VersionMyPageCollectionViewCell.identifier)
        
        // 섹션 헤더 등록
        self.register(MyPageCollectionHeaderView.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: MyPageCollectionHeaderView.identifier)
        // 섹션 풋터 등록
        self.register(MyPageCollectionFooterView.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                      withReuseIdentifier: MyPageCollectionFooterView.identifier)
        
    }
}
