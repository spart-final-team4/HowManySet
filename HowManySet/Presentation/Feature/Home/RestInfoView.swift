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
    private let restButtonText60 = "+1분"
    private let restButtonText30 = "+30초"
    private let restButtonText10 = "+10초"
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
    
    lazy var restTimeLabel = UILabel().then {
        $0.text = "00:00"
        $0.font = .monospacedDigitSystemFont(ofSize: 28, weight: .medium)
    }
    
    lazy var restButtonHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 14
    }
    
    lazy var restButton60 = UIButton().then {
        $0.backgroundColor = .darkGray
        $0.setTitle(restButtonText60, for: .normal)
        $0.layer.cornerRadius = 20
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
    }
    
    lazy var restButton30 = UIButton().then {
        $0.backgroundColor = .darkGray
        $0.setTitle(restButtonText30, for: .normal)
        $0.layer.cornerRadius = 20
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
    }
    
    lazy var restButton10 = UIButton().then {
        $0.backgroundColor = .darkGray
        $0.setTitle(restButtonText10, for: .normal)
        $0.layer.cornerRadius = 20
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
    }
    
    lazy var restResetButton = UIButton().then {
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
        $0.spacing = 28
        
        // MARK: - 내부 물 버튼 들 생성 및 바인딩
        for _ in 0..<5 {
            let waterButton = UIButton().then {
                $0.setImage(UIImage(systemName: "waterbottle"), for: .normal)
                $0.setImage(UIImage(systemName: "waterbottle.fill"), for: .selected)
                $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 32), forImageIn: .normal)
                $0.tintColor = .white
                $0.setTitleColor(.brand, for: .selected)
            }
            
            waterButton.rx.tap
                .bind { [weak waterButton]  in
                    guard let waterButton else { return }
                    waterButton.isSelected.toggle()
                    waterButton.tintColor = waterButton.isSelected ? .brand : .white
                }.disposed(by: disposeBag)
            
            $0.addArrangedSubview(waterButton)
        }
    }
    
    // MARK: - Initializer
    init(frame: CGRect, homeViewReactor: HomeViewReactor) {
        super.init(frame: frame)
        self.reactor = homeViewReactor
        
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI Methods
private extension RestInfoView {
    func setupUI() {
        setViewHiearchy()
        setConstraints()
        
        showRestInfo()
    }
    
    func setViewHiearchy() {
        self.addSubview(contentsVStack)
        contentsVStack.addArrangedSubviews(restLabelHStack, restButtonHStack,
                                           waterLabel, waterImageHStack)
        
        restLabelHStack.addArrangedSubviews(restLabel, restTimeLabel)
        restButtonHStack.addArrangedSubviews(
            restButton60,
            restButton30,
            restButton10,
            restResetButton)
    }
    
    func setConstraints() {
        
        contentsVStack.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        [restButton60, restButton30, restButton10, restResetButton].forEach {
            $0.snp.makeConstraints {
                $0.width.equalTo(self).multipliedBy(0.19)
                $0.height.equalTo(self).multipliedBy(0.27)
            }
        }
    }
}

// MARK: - Internal Methods
extension RestInfoView {
    
    func showRestInfo() {
        
        [restLabelHStack, restButtonHStack].forEach {
            $0.isHidden = false
        }
        
        [waterLabel, waterImageHStack].forEach {
            $0.isHidden = true
        }
    }
    
    func showWaterInfo() {
        [restLabelHStack, restButtonHStack].forEach {
            $0.isHidden = true
        }
        
        [waterLabel, waterImageHStack].forEach {
            $0.isHidden = false
        }
    }
}

// MARK: - Reactor Binding
extension RestInfoView {
    
    func bind(reactor: HomeViewReactor) {
        
        // MARK: Action
        restButton60.rx.tap
            .map { Reactor.Action.setRestTime(60) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        restButton30.rx.tap
            .map { Reactor.Action.setRestTime(30) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        restButton10.rx.tap
            .map { Reactor.Action.setRestTime(10) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        restResetButton.rx.tap
            .map { Reactor.Action.setRestTime(0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: State
        // HomeViewReactor의 상태를 구독하여 RestInfoView의 UI를 업데이트
        reactor.state.map { $0.restTime }
            .bind(onNext: { [weak self] restTime in
                guard let self else { return }
                self.restTimeLabel.text = restTime.toRestTimeLabel()
            })
            .disposed(by: disposeBag)
    }
}
