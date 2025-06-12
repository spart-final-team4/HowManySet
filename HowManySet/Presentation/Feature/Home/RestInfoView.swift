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
    private let restButtonText1 = "+1분"
    private let restButtonText2 = "+30초"
    private let restButtonText3 = "+10초"
    private let restResetButtonText = "초기화"
    private let doRestText = "휴식도 운동이에요"
    
    var disposeBag = DisposeBag()
    
    
    // MARK: - UI Components
    private lazy var restButtonHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 8
        $0.isUserInteractionEnabled = false
        $0.isHidden = true
    }
    
    private lazy var restButton1 = UIButton().then {
        $0.backgroundColor = .gray
        $0.setTitle(restButtonText1, for: .normal)
        $0.layer.cornerRadius = 10
    }
    
    private lazy var restButton2 = UIButton().then {
        $0.backgroundColor = .gray
        $0.setTitle(restButtonText2, for: .normal)
        $0.layer.cornerRadius = 10
    }
    
    private lazy var restButton3 = UIButton().then {
        $0.backgroundColor = .gray
        $0.setTitle(restButtonText3, for: .normal)
        $0.layer.cornerRadius = 10
    }
    
    private lazy var restResetButton = UIButton().then {
        $0.backgroundColor = .background
        $0.setTitle(restResetButtonText, for: .normal)
        $0.layer.cornerRadius = 10
    }
    
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
