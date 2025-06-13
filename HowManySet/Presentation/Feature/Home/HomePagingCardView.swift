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
    private let setCompleteText = "세트 완료"
    private let setText = "세트"
    private let repsText = "회"
    
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    lazy var mainContentVStack = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .fill
    }
    
    lazy var topLineHStack = UIStackView().then {
        $0.axis = .horizontal
    }
    
    lazy var topConentsVStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 20
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

    lazy var weightRepscontainerView = UIView().then {
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
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
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
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.textColor = .white
    }
    
    lazy var remaingRestTimeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 28, weight: .medium)
        $0.isHidden = true
    }
    
    lazy var setCompleteButton = UIButton().then {
        $0.backgroundColor = .brand
        $0.setTitle(setCompleteText, for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        $0.titleLabel?.textColor = .black
        $0.layer.cornerRadius = 12
    }
    
    lazy var restProgressBar = UIProgressView().then {
        $0.progressTintColor = .brand
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    
    // MARK: - Initializer
    init(frame: CGRect, reactor: HomePagingCardViewReactor) {
        super.init(frame: frame)
        self.reactor = reactor
            
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
        
        self.addSubview(mainContentVStack)
        
        mainContentVStack.addArrangedSubviews(
            topLineHStack,
            topConentsVStack,
            weightRepscontainerView,
            setCompleteButton,
            // 휴식 시 나타나는 뷰
            restProgressBar,
            remaingRestTimeLabel
        )
        
        topConentsVStack.addArrangedSubviews(topLineHStack, setProgressBar)
        topLineHStack.addArrangedSubviews(exerciseInfoHStack, spacer, optionButton)
        exerciseInfoHStack.addArrangedSubviews(exerciseNameLabel, exerciseSetLabel)
        weightRepscontainerView.addSubview(weightRepsHStack)
        weightRepsHStack.addArrangedSubviews(weightInfoVStack,
                                             repsInfoVStack)
        weightInfoVStack.addArrangedSubviews(weightImageView, weightLabel)
        
        repsInfoVStack.addArrangedSubviews(repsImageView, repsLabel)
    }
    
    func setConstraints() {
        
        mainContentVStack.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        topLineHStack.snp.makeConstraints {
            $0.horizontalEdges.equalTo(mainContentVStack)
        }
        
        setProgressBar.snp.makeConstraints {
            $0.height.equalTo(16)
        }
        
        weightRepscontainerView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(mainContentVStack)
            $0.height.equalToSuperview().multipliedBy(0.4)
        }
        
        weightRepsHStack.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        setCompleteButton.snp.makeConstraints {
            $0.height.equalTo(60)
        }
        
        restProgressBar.snp.makeConstraints {
            $0.height.equalTo(60)
        }
        
        remaingRestTimeLabel.snp.makeConstraints {
            $0.center.equalTo(restProgressBar)
        }
    }
}


// MARK: Internal Methods
extension HomePagingCardView {
    
    // TODO: 추후에 통합하여 리팩토링
    func showExerciseUI() {
        print(#function)
        setCompleteButton.isHidden = false
        [restProgressBar, remaingRestTimeLabel].forEach {
            $0.isHidden = true
        }
    }
    
    func showRestUI() {
        print(#function)
        setCompleteButton.isHidden = true
        [restProgressBar, remaingRestTimeLabel].forEach {
            $0.isHidden = false
        }
    }
    
}

// MARK: - Reactor Binding
extension HomePagingCardView {
    
    func bind(reactor: HomePagingCardViewReactor) {
        
        // MARK: - State
        reactor.state.map { $0.cardState }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] state in
                guard let self else { return }
                self.exerciseNameLabel.text = state.currentExerciseName
                self.exerciseSetLabel.text = "\(state.currentSetNumber) / \(state.totalSetCount)"
                self.weightLabel.text = "\(Int(state.currentWeight))\(state.currentUnit)"
                self.repsLabel.text = "\(state.currentReps)\(self.repsText)"
                
                // 세트 프로그레스바 업데이트
                self.setProgressBar.updateProgress(currentSet: state.setProgressAmount)
                debugPrint(state.setProgressAmount)
                
                if state.currentSetNumber == 1 {
                    self.setProgressBar.setupSegments(totalSets: state.totalSetCount)
                }
            })
            .disposed(by: disposeBag)
    }
}



