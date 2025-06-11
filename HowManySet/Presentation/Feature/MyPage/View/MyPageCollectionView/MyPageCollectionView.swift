//
//  MyPageCollectionView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/10/25.
//

import UIKit

final class MyPageCollectionView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
        setLayout()
        self.register(DefaultMyPageCollectionViewCell.self,
                      forCellWithReuseIdentifier: DefaultMyPageCollectionViewCell.identifier)
        self.register(VersionMyPageCollectionViewCell.self,
                      forCellWithReuseIdentifier: VersionMyPageCollectionViewCell.identifier)
        self.register(MyPageCollectionHeaderView.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: MyPageCollectionHeaderView.identifier)
        delegate = self
        dataSource = self
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 40)
        layout.minimumLineSpacing = 0
        
        self.collectionViewLayout = layout
        self.reloadData()
    }
    
}

extension MyPageCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return MyPageCollectionViewModel.model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MyPageCollectionViewModel.model[section].cellModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 && indexPath.row == 0 {
            guard let versionCell = collectionView.dequeueReusableCell(withReuseIdentifier: VersionMyPageCollectionViewCell.identifier,
                                                                       for: indexPath) as? VersionMyPageCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            versionCell.configure(model: MyPageCollectionViewModel.model[indexPath.section].cellModel[indexPath.row])
            return versionCell
        } else {
            guard let defaultCell = collectionView.dequeueReusableCell(withReuseIdentifier: DefaultMyPageCollectionViewCell.identifier,
                                                                for: indexPath) as? DefaultMyPageCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            defaultCell.configure(model: MyPageCollectionViewModel.model[indexPath.section].cellModel[indexPath.row])
            return defaultCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                               withReuseIdentifier: MyPageCollectionHeaderView.identifier,
                                                                               for: indexPath) as? MyPageCollectionHeaderView
            else { return UICollectionReusableView() }
            header.configure(model: MyPageCollectionViewModel.model[indexPath.section])
            return header
        default:
            return UICollectionReusableView()
        }
    }
}
