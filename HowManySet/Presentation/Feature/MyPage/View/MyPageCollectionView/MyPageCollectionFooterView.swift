//
//  MyPageCollectionFooterView.swift
//  HowManySet
//
//  Created by MJ Dev on 6/12/25.
//

import UIKit

final class MyPageCollectionFooterView: UICollectionReusableView {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
