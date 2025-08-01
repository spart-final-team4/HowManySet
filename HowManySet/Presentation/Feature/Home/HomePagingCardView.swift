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

final class HomePagingCardView: UIView {
    
    // MARK: - Properties
    private let setCompleteText = String(localized: "세트 완료")
    private let setText = String(localized: "세트")
    private let repsText = String(localized: "회")
    
    var disposeBag = DisposeBag()
    
    /// 현재 카드 뷰의 index
    /// WorkoutCardState의 index와 동일해야 함
    var index: Int
    
    // MARK: - UI Components
    private lazy var mainContentVStack = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .fill
    }
    
    private lazy var topLineHStack = UIStackView().then {
        $0.axis = .horizontal
    }
    
    private lazy var topConentsVStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 20
    }
    
    private lazy var spacer = UIView().then {
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    private lazy var exerciseInfoHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
    }
    
    private lazy var exerciseNameLabel = UILabel().then {
        $0.font = UIFont.pretendard(size: 20, weight: .bold)
    }
    
    lazy var editButton = UIButton().then {
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.tintColor = .label
    }
    
    lazy var setProgressBar = SetProgressBarView().then {
        $0.backgroundColor = .cardBackground
    }

    lazy var weightRepsButton = UIButton().then {
        $0.backgroundColor = .cardContentBG
        $0.layer.cornerRadius = 12
    }
    
    private lazy var weightRepsHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 70
        $0.isUserInteractionEnabled = false
    }
    
    private lazy var weightInfoVStack = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }
    
    private lazy var weightImageView = UIImageView().then {
        $0.image = UIImage(named: "brandDumbbell")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .brand
    }
    
    private lazy var weightLabel = UILabel().then {
        $0.font = UIFont.pretendard(size: 20, weight: .semibold)
        $0.textColor = .white
    }
    
    private lazy var repsInfoVStack = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }
    
    private lazy var repsImageView = UIImageView().then {
        let config = UIImage.SymbolConfiguration(pointSize: 40)
        $0.image = UIImage(systemName: "repeat", withConfiguration: config)
        $0.tintColor = .white
    }
    
    private lazy var repsLabel = UILabel().then {
        $0.font = UIFont.pretendard(size: 20, weight: .semibold)
        $0.textColor = .white
    }
    
    lazy var remainingRestTimeLabel = UILabel().then {
        $0.font = .monospacedDigitSystemFont(ofSize: 28, weight: .semibold)
        $0.isHidden = true
        $0.textColor = .white
    }
    
    lazy var setCompleteButton = UIButton().then {
        $0.backgroundColor = .brand
        $0.setTitle(setCompleteText, for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard(size: 20, weight: .semibold)
        $0.titleLabel?.textColor = .black
        $0.layer.cornerRadius = 12
    }
    
    lazy var restPlayPauseButton = UIButton().then {
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 22), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        $0.isUserInteractionEnabled = false
        $0.alpha = 0
        $0.tintColor = .white
    }
    
    lazy var restProgressBar = UIProgressView().then {
        $0.progressTintColor = .green7
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.isHidden = true
        $0.setProgress(0, animated: false)
    }
    
    // MARK: - Initializer
    init(frame: CGRect, index: Int) {
        self.index = index
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
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
            mainContentVStack,
            restProgressBar,
            remainingRestTimeLabel,
            restPlayPauseButton
        )
        
        mainContentVStack.addArrangedSubviews(
            topLineHStack,
            topConentsVStack,
            weightRepsButton,
            setCompleteButton
        )
        topConentsVStack.addArrangedSubviews(
            topLineHStack,
            setProgressBar
        )
        topLineHStack.addArrangedSubviews(
            exerciseInfoHStack,
            spacer,
            editButton
        )
        exerciseInfoHStack.addArrangedSubviews(
            exerciseNameLabel /*, exerciseSetLabel*/
        )
        weightRepsButton.addSubview(weightRepsHStack)
        weightRepsHStack.addArrangedSubviews(
            weightInfoVStack,
            repsInfoVStack
        )
        weightInfoVStack.addArrangedSubviews(
            weightImageView,
            weightLabel
        )
        repsInfoVStack.addArrangedSubviews(
            repsImageView,
            repsLabel
        )
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
        
        weightRepsButton.snp.makeConstraints {
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
            $0.edges.equalTo(setCompleteButton)
        }
        
        remainingRestTimeLabel.snp.makeConstraints {
            $0.center.equalTo(restProgressBar)
        }
        
        restPlayPauseButton.snp.makeConstraints {
            $0.centerY.equalTo(remainingRestTimeLabel)
            $0.trailing.equalTo(remainingRestTimeLabel.snp.leading).offset(-12)
        }
        
        weightImageView.snp.makeConstraints {
            $0.width.height.equalTo(40)
        }
    }
}


// MARK: Internal Methods
extension HomePagingCardView {
    
    // TODO: 추후에 통합하여 리팩토링
    func showExerciseUI() {

        [restProgressBar,
         remainingRestTimeLabel].forEach {
            $0.isHidden = true
        }
        restPlayPauseButton.isUserInteractionEnabled = false
        restPlayPauseButton.alpha = 0
        setCompleteButton.isUserInteractionEnabled = true
        setCompleteButton.alpha = 1
    }
    
    func showRestUI() {

        [restProgressBar,
         remainingRestTimeLabel].forEach {
            $0.isHidden = false
        }
        restPlayPauseButton.isUserInteractionEnabled = true
        restPlayPauseButton.alpha = 1
        setCompleteButton.isUserInteractionEnabled = false
        setCompleteButton.alpha = 0
    }
    
    func configure(with state: WorkoutCardState, isEdited: Bool? = nil) {
        exerciseNameLabel.text = state.currentExerciseName
        weightLabel.text = "\(Int(state.currentWeightForSave))\(state.currentUnitForSave)"
        repsLabel.text = "\(state.currentRepsForSave)\(repsText)"
        if state.currentSetNumber == 1 || (isEdited != nil) {
            self.setProgressBar.setupSegments(totalSets: state.totalSetCount)
        }
        setProgressBar.updateProgress(currentSet: state.setProgressAmount)
    }
}


