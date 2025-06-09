//
//  HomeView.swift
//  HowManySet
//
//  Created by 정근호 on 6/7/25.
//

import UIKit
import SnapKit
import Then

final class HomePagingCardView: UIView {
    
    // MARK: - Properties
    private let setCompleteText = "세트 완료"
    private let restText = "휴식 중"
    private let doRestText = "휴식도 운동이에요"
    private let restButtonText1 = "+1분"
    private let restButtonText2 = "+30초"
    private let restButtonText3 = "+10초"
    private let restResetButtonText = "초기화"

    
    // MARK: - UI Components
    private lazy var mainVStack = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
    }
    
    private lazy var topInfoHStack = UIStackView().then {
        $0.axis = .horizontal
    }
    
    private lazy var spacer = UIView().then {
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    private lazy var exerciseInfoHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
    }
    
    private lazy var exerciseNameLabel = UILabel().then {
        $0.text = "랫풀다운"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private lazy var restLabel = UILabel().then {
        $0.text = restText
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.alpha = 0
    }
    
    private lazy var exerciseSetLabel = UILabel().then {
        $0.text = "1 / 5"
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .textSecondary
    }

    private lazy var optionButton = UIButton().then {
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24), forImageIn: .normal)
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.tintColor = .label
    }
    
    private lazy var setProgressBar = SetProgressBarView().then {
        $0.backgroundColor = .cardBackground
    }
    
    private lazy var restButtonHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
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
    
    private lazy var currentSetLabel = UILabel().then {
        $0.text = "1 세트"
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .cardContentBG
        $0.layer.cornerRadius = 12
    }
    
    private lazy var weightRepsHStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 70
    }
    
    private lazy var weightInfoVStack = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }
    
    private lazy var weightImageView = UIImageView().then {
        let config = UIImage.SymbolConfiguration(pointSize: 40)
        $0.image = UIImage(systemName: "dumbbell", withConfiguration: config)
        $0.tintColor = .brand
    }
    
    private lazy var weightLabel = UILabel().then {
        $0.text = "60kg"
        $0.font = .systemFont(ofSize: 24)
        $0.textColor = .white
    }
    
    private lazy var repsInfoVStack = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }
    
    private lazy var repsImageView = UIImageView().then {
        let config = UIImage.SymbolConfiguration(pointSize: 40)
        $0.image = UIImage(systemName: "dumbbell", withConfiguration: config)
        $0.tintColor = .brand
    }
    
    private lazy var repsLabel = UILabel().then {
        $0.text = "10회"
        $0.font = .systemFont(ofSize: 24)
        $0.textColor = .white
    }
    
    private lazy var restVStack = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alpha = 0
    }
    
    private lazy var restImageView = UIImageView().then {
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        $0.image = UIImage(systemName: "waterbottle", withConfiguration: config)
        $0.tintColor = .white
    }
    
    private lazy var doRestLabel = UILabel().then {
        $0.text = doRestText
        $0.font = .systemFont(ofSize: 20, weight: .regular)
    }
    
    private lazy var remaingRestTimeLabel = UILabel().then {
        $0.text = "01:30"
        $0.font = .systemFont(ofSize: 28, weight: .medium)
        $0.alpha = 0
    }
    
    lazy var setCompleteButton = UIButton().then {
        $0.backgroundColor = .brand
        $0.setTitle(accessibilityElementsHidden ? "" : setCompleteText, for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        $0.titleLabel?.textColor = .black
        $0.layer.cornerRadius = 12
    }
    
    private lazy var restProgressBar = UIProgressView().then {
        $0.progress = .greatestFiniteMagnitude
        $0.progressTintColor = .brand
        $0.layer.cornerRadius = 12
        $0.alpha = 0
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
        self.addSubview(mainVStack)
        
        mainVStack.addArrangedSubviews(
            topInfoHStack,
            setProgressBar,
            restButtonHStack,
            currentSetLabel,
            containerView,
            setCompleteButton,
            
            restProgressBar
        )

        topInfoHStack.addArrangedSubviews(exerciseInfoHStack, spacer, optionButton)
        exerciseInfoHStack.addArrangedSubviews(exerciseNameLabel, exerciseSetLabel)
        containerView.addSubviews(weightRepsHStack,
                                 restVStack)
        weightRepsHStack.addArrangedSubviews(weightInfoVStack, repsInfoVStack)
        weightInfoVStack.addArrangedSubviews(weightImageView, weightLabel)
        repsInfoVStack.addArrangedSubviews(repsImageView, repsLabel)
        
        restButtonHStack.addArrangedSubviews(restButton1, restButton2, restButton3, restResetButton)
        restVStack.addArrangedSubviews(restImageView, doRestLabel)
        
        restProgressBar.addSubview(remaingRestTimeLabel)
    }
    
    func setConstraints() {
        mainVStack.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.verticalEdges.equalToSuperview().inset(28)
        }
                
        setProgressBar.snp.makeConstraints {
            $0.height.equalTo(12)
            $0.leading.trailing.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.height.equalTo(self.snp.height).multipliedBy(0.39)
        }
    
        weightRepsHStack.snp.makeConstraints {
            $0.height.equalTo(containerView.snp.height).multipliedBy(0.5)
            $0.centerX.centerY.equalToSuperview()
        }
        
        setCompleteButton.snp.makeConstraints {
            $0.height.equalTo(60)
        }
        
        restButtonHStack.snp.makeConstraints {
            $0.centerX.equalToSuperview()
        }
        
        restVStack.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }

        remaingRestTimeLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        restProgressBar.snp.makeConstraints {
            $0.height.equalTo(60)
        }
    }
}

// MARK: Internal Methods
extension HomePagingCardView {
    func setRestUI() {
        
        print(#function)

        restButtonHStack.isUserInteractionEnabled = true
        [restLabel, restVStack, remaingRestTimeLabel, restProgressBar].forEach {
            $0.alpha = 1
        }
        
        exerciseNameLabel.text = restText
        
        setCompleteButton.isUserInteractionEnabled = false
        [setCompleteButton, setProgressBar].forEach {
            $0.isHidden = true
        }
        
        [restButtonHStack, restProgressBar].forEach {
            $0.isHidden = false
        }
        
        [currentSetLabel, weightRepsHStack].forEach {
            $0.alpha = 0
        }
    }
    
    func setExerciseUI() {
        
        print(#function)
        
        restButtonHStack.isUserInteractionEnabled = false
        [restLabel, restVStack, remaingRestTimeLabel].forEach {
            $0.alpha = 0
        }
        
        exerciseNameLabel.text = "랫풀다운"
        
        setCompleteButton.isUserInteractionEnabled = true
        
        restProgressBar.isUserInteractionEnabled = false
        
        [setCompleteButton, setProgressBar].forEach {
            $0.isHidden = false
        }
        
        [restButtonHStack, restProgressBar].forEach {
            $0.isHidden = true
        }
        
        [currentSetLabel, weightRepsHStack].forEach {
            $0.alpha = 1
        }
    }
}


