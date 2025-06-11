//
//  RestInfoView.swift
//  HowManySet
//
//  Created by 정근호 on 6/12/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

final class RestInfoView: UIView, View {
    
    // MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    // MARK: - Initializer
    init(frame: CGRect, reactor: RestInfoViewReactor) {
        super.init(frame: frame)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI Methods
private extension RestInfoView {
    func setupUI() {
        
    }
    
    func setViewHiearchy() {
        
    }
    
    func setConstraints() {
        
    }
}

// MARK: - Reactor Binding
extension RestInfoView {
    
    func bind(reactor: RestInfoViewReactor) {
        
    }
}
