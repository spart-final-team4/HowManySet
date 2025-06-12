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
    private let restText = "현재 설정된 휴식 시간"
    private let waterText = "물 한잔 챙겼다면, 클릭!"
    
    var disposeBag = DisposeBag()
    
    
    // MARK: - UI Components
    private lazy var contentsVStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 6
        $0.distribution = .fillProportionally
        $0.alignment = .center
    }
    
    private lazy var restLabelHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 20
    }
    
    private lazy var restLabel = UILabel().then {
        $0.text = restText
        $0.font = .systemFont(ofSize: 16, weight: .medium)
    }
    
    private lazy var restTimeLabel = UILabel().then {
        $0.text = "00:00"
        $0.font = .systemFont(ofSize: 28, weight: .medium)
    }
    
    private lazy var restButtonHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 14
    }
    
    private lazy var restButton1 = UIButton().then {
        $0.backgroundColor = .darkGray
        $0.setTitle(restButtonText1, for: .normal)
        $0.layer.cornerRadius = 20
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
    }
    
    private lazy var restButton2 = UIButton().then {
        $0.backgroundColor = .darkGray
        $0.setTitle(restButtonText2, for: .normal)
        $0.layer.cornerRadius = 20
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
    }
    
    private lazy var restButton3 = UIButton().then {
        $0.backgroundColor = .darkGray
        $0.setTitle(restButtonText3, for: .normal)
        $0.layer.cornerRadius = 20
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
    }
    
    private lazy var restResetButton = UIButton().then {
        $0.backgroundColor = .background
        $0.setTitle(restResetButtonText, for: .normal)
        $0.layer.cornerRadius = 20
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
    }
    
    private lazy var waterLabel = UILabel().then {
        $0.text = waterText
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
    }
    
    private lazy var waterImageHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        
        for _ in 0..<5 {
            let waterButton = UIButton().then {
                $0.setImage(UIImage(systemName: "waterbottle"), for: .normal)
                $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
                $0.tintColor = .white
                $0.setTitleColor(.brand, for: .selected)
            }
            $0.addArrangedSubview(waterButton)
        }
    }
    
    // MARK: - Initializer
    init(frame: CGRect, reactor: RestInfoViewReactor) {
        super.init(frame: frame)
        self.reactor = reactor
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI Methods
private extension RestInfoView {
    func setupUI() {
        setViewHiearchy()
        setConstraints()
        
        setRestUI()
    }
    
    func setViewHiearchy() {
        self.addSubview(contentsVStack)
        contentsVStack.addArrangedSubviews(restLabelHStack, restButtonHStack,
                         waterLabel, waterImageHStack)
        
        restLabelHStack.addArrangedSubviews(restLabel, restTimeLabel)
        restButtonHStack.addArrangedSubviews(
            restButton1,
            restButton2,
            restButton3,
            restResetButton)
    }
    
    func setConstraints() {
        
        contentsVStack.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        [restButton1, restButton2, restButton3, restResetButton].forEach {
            $0.snp.makeConstraints {
                $0.width.equalTo(70)
                $0.height.equalTo(36)
            }
        }
    }
    
    func setRestUI() {
        [waterLabel, waterImageHStack].forEach {
            $0.isHidden = true
        }
    }
    
    func setWaterUI() {
        
    }
    
}

// MARK: - Reactor Binding
extension RestInfoView {
    
    func bind(reactor: RestInfoViewReactor) {
        
    }
}
