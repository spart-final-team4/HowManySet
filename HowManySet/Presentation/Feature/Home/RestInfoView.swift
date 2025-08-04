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
    private let restButtonText60 = String(localized: "+1분")
    private let restButtonText30 = String(localized: "+30초")
    private let restButtonText10 = String(localized: "+10초")
    private let restResetButtonText = String(localized: "초기화")
    private let restText = String(localized: "현재 설정된 휴식 시간")
    private let waterText = String(localized: "물 한잔 챙겼다면, 클릭!")
    
    // SE3 - 375 x 667 pt
    private let customInset: CGFloat = UIScreen.main.bounds.width <= 375 ? 16 : 20
    private let buttonHeight: CGFloat =  UIScreen.main.bounds.width <= 375 ? 30 : 36

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
        $0.font = .pretendard(size: 16, weight: .medium)
        $0.adjustsFontForContentSizeCategory = true
    }
    
    lazy var restTimeLabel = UILabel().then {
        $0.text = "00:00"
        $0.font = .monospacedDigitSystemFont(ofSize: 28, weight: .medium)
        $0.adjustsFontForContentSizeCategory = true
    }
    
    lazy var restButtonHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 14
    }
    
    lazy var restButton60 = UIButton().then {
        $0.backgroundColor = .grey5
        $0.setTitle(restButtonText60, for: .normal)
        $0.layer.cornerRadius = buttonHeight/2
        $0.titleLabel?.font = .pretendard(size: 16, weight: .regular)
        $0.tag = 60
    }

    lazy var restButton30 = UIButton().then {
        $0.backgroundColor = .grey5
        $0.setTitle(restButtonText30, for: .normal)
        $0.layer.cornerRadius = buttonHeight/2
        $0.titleLabel?.font = .pretendard(size: 16, weight: .regular)
        $0.tag = 30
    }

    lazy var restButton10 = UIButton().then {
        $0.backgroundColor = .grey5
        $0.setTitle(restButtonText10, for: .normal)
        $0.layer.cornerRadius = buttonHeight/2
        $0.titleLabel?.font = .pretendard(size: 16, weight: .regular)
        $0.tag = 10
    }

    lazy var restResetButton = UIButton().then {
        $0.backgroundColor = .background
        $0.setTitle(restResetButtonText, for: .normal)
        $0.layer.cornerRadius = buttonHeight/2
        $0.titleLabel?.font = .pretendard(size: 16, weight: .regular)
        $0.tag = 0
    }
    
    private lazy var waterLabel = UILabel().then {
        $0.text = waterText
        $0.font = .pretendard(size: 16, weight: .semibold)
    }
    
    private lazy var waterImageHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 28
        
        // MARK: - 내부 물 버튼들 생성 및 바인딩
        for _ in 0..<5 {
            let waterButton = UIButton().then {
                $0.setImage(UIImage(named: "water"), for: .normal)
                $0.setImage(UIImage(named: "waterFill"), for: .selected)
                $0.contentMode = .scaleAspectFit
            }
            
            waterButton.rx.tap
                .bind { [weak waterButton]  in
                    guard let waterButton else { return }
                    waterButton.isSelected.toggle()
                }.disposed(by: disposeBag)
            
            $0.addArrangedSubview(waterButton)
            
            waterButton.snp.makeConstraints {
                $0.width.height.equalTo(buttonHeight)
            }
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
        contentsVStack.addArrangedSubviews(
            restLabelHStack,
            restButtonHStack,
            waterLabel,
            waterImageHStack
        )
        restLabelHStack.addArrangedSubviews(
            restLabel,
            restTimeLabel
        )
        restButtonHStack.addArrangedSubviews(
            restButton60,
            restButton30,
            restButton10,
            restResetButton
        )
    }
    
    func setConstraints() {
        
        contentsVStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(customInset)
        }
        
        [restButton60, restButton30, restButton10, restResetButton].forEach {
            $0.snp.makeConstraints {
                $0.width.equalTo(self).multipliedBy(0.19)
                $0.height.equalTo(buttonHeight)
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
        [restButton10, restButton30, restButton60, restResetButton].forEach { button in
            button.rx.tap
                .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                .do(onNext: {
                    UIView.animate(withDuration: 0.1,
                                   animations: {
                        button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                        button.alpha = 0.9
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.1) {
                            button.transform = .identity
                            button.alpha = 1
                        }
                    })
                })
                .map { Reactor.Action.setRestTime(Float(button.tag)) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
        
        // MARK: State
        // HomeViewReactor의 상태를 구독하여 RestInfoView의 UI를 업데이트
        reactor.state.map { $0.restTime }
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] restTime in
                guard let self else { return }
                self.restTimeLabel.text = Int(restTime).toRestTimeLabel()
            })
            .disposed(by: disposeBag)
    }
}
