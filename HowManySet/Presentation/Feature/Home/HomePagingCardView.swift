//
//  HomeView.swift
//  HowManySet
//
//  Created by 정근호 on 6/7/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

final class HomePagingCardView: UIView, View {
    
    // MARK: - Properties
    private let doRestText = "휴식도 운동이에요"
    private let restText = "휴식 중"
    private let restButtonText1 = "+1분"
    private let restButtonText2 = "+30초"
    private let restButtonText3 = "+10초"
    private let restResetButtonText = "초기화"
    private let setCompleteText = "세트 완료"
    private let setText = "세트"
    private let repsText = "회"
    
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    lazy var topLineHStack = UIStackView().then {
        $0.axis = .horizontal
    }
    
    lazy var topConentsVStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
    }
    
    lazy var spacer = UIView().then {
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    lazy var exerciseInfoHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
    }
    
    lazy var exerciseNameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    lazy var restLabel = UILabel().then {
        $0.text = restText
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    lazy var exerciseSetLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .textSecondary
    }
    
    lazy var optionButton = UIButton().then {
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.tintColor = .label
    }
    
    lazy var setProgressBar = SetProgressBarView().then {
        $0.backgroundColor = .cardBackground
    }
    
    lazy var restButtonHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 8
        $0.isUserInteractionEnabled = false
        $0.isHidden = true
    }
    
    lazy var restButton1 = UIButton().then {
        $0.backgroundColor = .gray
        $0.setTitle(restButtonText1, for: .normal)
        $0.layer.cornerRadius = 10
    }
    
    lazy var restButton2 = UIButton().then {
        $0.backgroundColor = .gray
        $0.setTitle(restButtonText2, for: .normal)
        $0.layer.cornerRadius = 10
    }
    
    lazy var restButton3 = UIButton().then {
        $0.backgroundColor = .gray
        $0.setTitle(restButtonText3, for: .normal)
        $0.layer.cornerRadius = 10
    }
    
    lazy var restResetButton = UIButton().then {
        $0.backgroundColor = .background
        $0.setTitle(restResetButtonText, for: .normal)
        $0.layer.cornerRadius = 10
    }
    
    lazy var currentSetLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textAlignment = .left
    }
    
    lazy var containerView = UIView().then {
        $0.backgroundColor = .cardContentBG
        $0.layer.cornerRadius = 12
    }
    
    lazy var weightRepsHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 70
    }
    
    lazy var weightInfoVStack = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }
    
    lazy var weightImageView = UIImageView().then {
        let config = UIImage.SymbolConfiguration(pointSize: 40)
        $0.image = UIImage(systemName: "dumbbell", withConfiguration: config)
        $0.tintColor = .brand
    }
    
    lazy var weightLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 24)
        $0.textColor = .white
    }
    
    lazy var repsInfoVStack = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }
    
    lazy var repsImageView = UIImageView().then {
        let config = UIImage.SymbolConfiguration(pointSize: 40)
        $0.image = UIImage(systemName: "repeat", withConfiguration: config)
        $0.tintColor = .white
    }
    
    lazy var repsLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 24)
        $0.textColor = .white
    }
    
    lazy var restInfoVStack = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .center
        $0.spacing = 20
    }
    
    lazy var restImageView = UIImageView().then {
        let config = UIImage.SymbolConfiguration(pointSize: 40)
        $0.image = UIImage(systemName: "waterbottle", withConfiguration: config)
        $0.tintColor = .white
    }
    
    lazy var doRestLabel = UILabel().then {
        $0.text = doRestText
        $0.font = .systemFont(ofSize: 20, weight: .regular)
    }
    
    lazy var remaingRestTimeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 28, weight: .medium)
    }
    
    lazy var setCompleteButton = UIButton().then {
        $0.backgroundColor = .brand
        $0.setTitle(accessibilityElementsHidden ? "" : setCompleteText, for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        $0.titleLabel?.textColor = .black
        $0.layer.cornerRadius = 12
    }
    
    lazy var restProgressBar = UIProgressView().then {
        $0.progressTintColor = .brand
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: UI Methods
private extension HomePagingCardView {
    func setupUI() {
        backgroundColor = .cardBackground
        setViewHiearchy()
        setConstraints()
    }
    
    func setViewHiearchy() {
        self.addSubviews(
            topLineHStack,
            topConentsVStack,
            currentSetLabel,
            containerView,
            setCompleteButton,
            
            restProgressBar,
            remaingRestTimeLabel
        )
        
        topConentsVStack.addArrangedSubviews(topLineHStack, setProgressBar, restButtonHStack, currentSetLabel)
        topLineHStack.addArrangedSubviews(exerciseInfoHStack, spacer, optionButton)
        
        exerciseInfoHStack.addArrangedSubviews(exerciseNameLabel, restLabel, exerciseSetLabel)
        containerView.addSubviews(weightRepsHStack,
                                  restInfoVStack)
        weightRepsHStack.addArrangedSubviews(weightInfoVStack,
                                             repsInfoVStack)
        weightInfoVStack.addArrangedSubviews(weightImageView, weightLabel)
        
        repsInfoVStack.addArrangedSubviews(repsImageView, repsLabel)
        restButtonHStack.addArrangedSubviews(restButton1, restButton2, restButton3, restResetButton)
        restInfoVStack.addArrangedSubviews(restImageView, doRestLabel)
    }
    
    func setConstraints() {
        
        topConentsVStack.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(topConentsVStack.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.39)
        }
        
        setProgressBar.snp.makeConstraints {
            $0.height.equalTo(16)
        }
        
        weightRepsHStack.snp.makeConstraints {
            $0.height.equalTo(containerView.snp.height).multipliedBy(0.5)
            $0.center.equalToSuperview()
        }
        
        currentSetLabel.snp.makeConstraints {
            $0.height.equalTo(16)
        }
        
        restInfoVStack.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        setCompleteButton.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(60)
        }
        
        restProgressBar.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(60)
        }
        
        remaingRestTimeLabel.snp.makeConstraints {
            $0.center.equalTo(restProgressBar)
        }
    }
}

// MARK: UI Methods
private extension HomePagingCardView {
    func updateContainerViewConstraint() {
        containerView.snp.updateConstraints {
            let offset: CGFloat = currentSetLabel.isHidden ? 38 : 24
            $0.top.equalTo(topConentsVStack.snp.bottom).offset(offset)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.39)
        }
    }
}

// MARK: Internal Methods
extension HomePagingCardView {
    
    // TODO: 추후에 통합하여 리팩토링
    func showExerciseUI() {
        print(#function)
        setCompleteButton.isUserInteractionEnabled = true
        restButtonHStack.isUserInteractionEnabled = false
        [restButtonHStack, restProgressBar, restLabel, restInfoVStack, remaingRestTimeLabel, restLabel].forEach {
            $0.isHidden = true
        }
        [setCompleteButton, setProgressBar, weightRepsHStack, currentSetLabel, exerciseNameLabel].forEach {
            $0.isHidden = false
        }
        updateContainerViewConstraint()
    }
    
    func showRestUI() {
        print(#function)
        setCompleteButton.isUserInteractionEnabled = false
        restButtonHStack.isUserInteractionEnabled = true
        [setCompleteButton, setProgressBar, weightRepsHStack, currentSetLabel, exerciseNameLabel].forEach {
            $0.isHidden = true
        }
        [restButtonHStack, restProgressBar, restLabel, restInfoVStack, remaingRestTimeLabel, restProgressBar, restLabel].forEach {
            $0.isHidden = false
        }
        updateContainerViewConstraint()
    }
    
}

// MARK: - Reactor Binding
extension HomePagingCardView {
    
    func bind(reactor: HomePagingCardViewReactor) {
        
        // MARK: - State
        reactor.state.map { $0.cardState }
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] state in
                guard let self else { return }
                self.exerciseNameLabel.text = state.currentExerciseName
                self.exerciseSetLabel.text = "\(state.currentSetNumber) / \(state.totalSetCount)"
                self.currentSetLabel.text = "\(state.currentSetNumber)\(self.setText)"
                self.weightLabel.text = "\(Int(state.currentWeight))\(state.currentUnit)"
                self.repsLabel.text = "\(state.currentReps)\(self.repsText)"
                
                self.setProgressBar.updateProgress(currentSet: state.setProgressAmount)
                
                if state.currentSetNumber == 1 {
                    self.setProgressBar.setupSegments(totalSets: state.totalSetCount)
                }
            })
            .disposed(by: disposeBag)
        
      // TODO: 기존 휴식 시간 로직은 UI 변경 시 휴식 뷰에 적용!
        
    }
}



